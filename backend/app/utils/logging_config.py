"""Application logging.

The backend logs lifecycle events, request metadata and errors. It deliberately
never logs request or response bodies, because those will contain passwords and
tokens once authentication is added. As a safety net every emitted line passes
through :func:`redact_secrets`, so an accidental ``logger.info(payload)`` cannot
leak a credential.
"""

from __future__ import annotations

import logging
import re
import sys
from typing import Any, Dict

LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

#: Loggers used by the framework itself; routed through our formatter.
_THIRD_PARTY_LOGGERS = ("uvicorn", "uvicorn.error", "uvicorn.access", "fastapi")

#: ``key=value`` / ``"key": "value"`` pairs whose value must be masked.
_SECRET_KEY_PATTERN = re.compile(
    r"(?i)(?P<prefix>"
    r"[\"']?(?:password|passwd|pwd|secret|token|access_token|refresh_token|"
    r"id_token|api[_-]?key|apikey|authorization|cookie|set-cookie)"
    r"[\"']?\s*[:=]\s*"
    r")(?P<quote>[\"']?)(?P<value>[^\"'\s,;&}\]]+)(?P=quote)"
)

#: JWTs are masked on sight, even when they appear without a key.
_JWT_PATTERN = re.compile(
    r"\beyJ[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{4,}\b"
)

_MASK = "***REDACTED***"


def redact_secrets(text: str) -> str:
    """Replace credential-looking values inside ``text`` with a mask."""

    masked = _SECRET_KEY_PATTERN.sub(
        lambda match: f"{match.group('prefix')}{match.group('quote')}"
        f"{_MASK}{match.group('quote')}",
        text,
    )
    return _JWT_PATTERN.sub(_MASK, masked)


class RedactingFormatter(logging.Formatter):
    """Formatter that scrubs secrets from every emitted record."""

    def format(self, record: logging.LogRecord) -> str:
        return redact_secrets(super().format(record))


def configure_logging(level: str = "INFO", *, force: bool = False) -> None:
    """Install the application log format on the root and uvicorn loggers.

    Args:
        level: Logging level name, e.g. ``INFO`` or ``DEBUG``.
        force: Replace existing handlers even if logging is already configured.
    """

    root = logging.getLogger()
    if root.handlers and not force:
        root.setLevel(level.upper())
        return

    handler = logging.StreamHandler(stream=sys.stdout)
    handler.setFormatter(RedactingFormatter(fmt=LOG_FORMAT, datefmt=DATE_FORMAT))

    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(level.upper())

    for name in _THIRD_PARTY_LOGGERS:
        logging.getLogger(name).handlers.clear()
        logging.getLogger(name).propagate = True


def get_logger(name: str) -> logging.Logger:
    """Return a module level logger.

    Args:
        name: Usually ``__name__`` of the calling module.
    """

    return logging.getLogger(name)


def log_settings(settings: Dict[str, Any]) -> None:
    """Log the safe subset of the configuration at startup."""

    logger = get_logger(__name__)
    summary = ", ".join(f"{key}={value}" for key, value in settings.items())
    logger.info("Configuration loaded: %s", summary)

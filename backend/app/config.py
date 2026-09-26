"""Application configuration.

Every environment-specific value is read from environment variables (optionally
sourced from a local ``.env`` file). Nothing sensitive or machine specific is
hard-coded here, and the values are validated once at import time so a bad
configuration fails fast instead of at the first request.
"""

from __future__ import annotations

import json
from enum import Enum
from functools import lru_cache
from typing import Annotated, Any, List

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict


class Environment(str, Enum):
    """Deployment environments supported by the backend."""

    DEVELOPMENT = "development"
    TEST = "test"
    STAGING = "staging"
    PRODUCTION = "production"


def _default_cors_origins() -> List[str]:
    """Local origins used by the Flutter app and common dev tooling.

    ``10.0.2.2`` is how the Android emulator reaches the host machine, so it has
    to be allowed explicitly for the Flutter Android build to talk to a locally
    running backend.
    """

    return [
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://127.0.0.1:8000",
        "http://10.0.2.2:8000",
    ]


class Settings(BaseSettings):
    """Typed application settings.

    Field names map to upper-case environment variables, for example
    ``APP_NAME=EduForge AI API`` sets :attr:`app_name`.
    """

    model_config = SettingsConfigDict(
        # The first readable file wins; the second entry allows starting the
        # server from the repository root as well as from ``backend/``.
        env_file=(".env", "backend/.env"),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # --- Application identity -------------------------------------------------
    app_name: str = "EduForge AI API"
    app_version: str = "1.0.0"
    app_description: str = (
        "Backend API for the EduForge AI learning platform. "
        "Upload study PDFs, ask questions, generate quizzes and receive "
        "personalised learning recommendations."
    )

    # --- Runtime --------------------------------------------------------------
    environment: Environment = Environment.DEVELOPMENT
    debug: bool = True
    log_level: str = "INFO"

    # --- API ------------------------------------------------------------------
    api_prefix: str = "/api/v1"
    docs_enabled: bool = True
    cors_origins: Annotated[List[str], NoDecode] = Field(
        default_factory=_default_cors_origins
    )
    cors_allow_credentials: bool = True

    @field_validator("cors_origins", mode="before")
    @classmethod
    def _parse_cors_origins(cls, value: Any) -> Any:
        """Accept both ``a,b`` and JSON ``["a","b"]`` forms from the environment.

        The field is annotated with :class:`~pydantic_settings.NoDecode` so the
        raw environment string reaches this validator. Without it pydantic-settings
        tries to JSON-decode complex fields first and raises ``SettingsError``
        before this parser ever runs.
        """

        if isinstance(value, str):
            raw = value.strip()
            if not raw:
                return []
            if raw.startswith("[") and raw.endswith("]"):
                try:
                    return json.loads(raw)
                except json.JSONDecodeError as exc:  # pragma: no cover - defensive
                    raise ValueError(
                        "CORS_ORIGINS must be a comma separated list of origins "
                        "or a JSON array of origins."
                    ) from exc
            return [origin.strip() for origin in raw.split(",") if origin.strip()]
        return value

    @field_validator("api_prefix")
    @classmethod
    def _normalise_api_prefix(cls, value: str) -> str:
        """Guarantee a leading slash and no trailing slash."""

        prefix = value.strip().rstrip("/")
        if not prefix:
            return ""
        return prefix if prefix.startswith("/") else f"/{prefix}"

    @field_validator("log_level")
    @classmethod
    def _normalise_log_level(cls, value: str) -> str:
        level = value.strip().upper()
        if level not in {"CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG", "NOTSET"}:
            raise ValueError(
                "LOG_LEVEL must be one of CRITICAL, ERROR, WARNING, INFO or DEBUG"
            )
        return level

    @model_validator(mode="after")
    def _validate_runtime_safety(self) -> "Settings":
        """Refuse unsafe combinations instead of starting in a broken state."""

        if "*" in self.cors_origins and self.cors_allow_credentials:
            raise ValueError(
                "CORS_ORIGINS='*' cannot be combined with credentials. List the "
                "explicit allowed origins instead."
            )

        if self.environment is Environment.PRODUCTION and "*" in self.cors_origins:
            raise ValueError(
                "CORS_ORIGINS must never be '*' in production. Allowing every "
                "origin lets any website call this API with the user's "
                "credentials."
            )

        return self

    @property
    def is_production(self) -> bool:
        return self.environment is Environment.PRODUCTION

    @property
    def is_development(self) -> bool:
        return self.environment in {Environment.DEVELOPMENT, Environment.TEST}

    @property
    def docs_url(self) -> str | None:
        return "/docs" if self.docs_enabled else None

    @property
    def redoc_url(self) -> str | None:
        return "/redoc" if self.docs_enabled else None

    @property
    def openapi_url(self) -> str | None:
        return f"{self.api_prefix}/openapi.json" if self.docs_enabled else None

    def public_summary(self) -> dict[str, Any]:
        """Configuration that is safe to log or expose on the root endpoint."""

        return {
            "app_name": self.app_name,
            "app_version": self.app_version,
            "environment": self.environment.value,
            "debug": self.debug,
            "api_prefix": self.api_prefix,
            "docs_enabled": self.docs_enabled,
        }


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return the process-wide settings singleton.

    Cached so the ``.env`` file is read once and every module observes the same
    values.
    """

    return Settings()

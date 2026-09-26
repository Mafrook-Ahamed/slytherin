"""Tests for configuration parsing, validation and secret redaction."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from app.config import Environment, Settings
from app.utils.errors import AppError, NotFoundError, error_payload
from app.utils.logging_config import redact_secrets


#: Environment variables that :data:`app.config.Settings` reads. Cleared before
#: asserting on defaults so the result does not depend on ``conftest``.
_SETTINGS_ENV_VARS = (
    "APP_NAME",
    "APP_VERSION",
    "ENVIRONMENT",
    "DEBUG",
    "LOG_LEVEL",
    "API_PREFIX",
    "DOCS_ENABLED",
    "CORS_ORIGINS",
    "CORS_ALLOW_CREDENTIALS",
)


def test_defaults_match_documented_values(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A missing .env file must still produce a usable configuration."""

    for name in _SETTINGS_ENV_VARS:
        monkeypatch.delenv(name, raising=False)

    settings = Settings(_env_file=None)

    assert settings.app_name == "EduForge AI API"
    assert settings.app_version == "1.0.0"
    assert settings.environment is Environment.DEVELOPMENT
    assert settings.api_prefix == "/api/v1"
    assert settings.docs_enabled is True


def test_cors_origins_accept_comma_separated_string() -> None:
    """CORS_ORIGINS must parse the plain comma separated form."""

    settings = Settings(
        _env_file=None,
        CORS_ORIGINS="http://localhost:3000, http://localhost:8080",
    )

    assert settings.cors_origins == [
        "http://localhost:3000",
        "http://localhost:8080",
    ]


def test_cors_origins_accept_json_list() -> None:
    """The JSON list form keeps working for deployment platforms."""

    settings = Settings(
        _env_file=None,
        CORS_ORIGINS='["https://app.eduforge.ai"]',
    )

    assert settings.cors_origins == ["https://app.eduforge.ai"]


def test_api_prefix_is_normalised() -> None:
    """The prefix always starts with a slash and has no trailing slash."""

    assert Settings(_env_file=None, API_PREFIX="api/v2/").api_prefix == "/api/v2"


def test_wildcard_origin_with_credentials_is_rejected() -> None:
    """'*' plus credentials is rejected at configuration time."""

    with pytest.raises(ValidationError):
        Settings(
            _env_file=None,
            CORS_ORIGINS="*",
            CORS_ALLOW_CREDENTIALS=True,
        )


def test_wildcard_origin_is_rejected_in_production() -> None:
    """Production must never start with an unrestricted CORS policy."""

    with pytest.raises(ValidationError):
        Settings(
            _env_file=None,
            ENVIRONMENT="production",
            CORS_ORIGINS="*",
            CORS_ALLOW_CREDENTIALS=False,
        )


def test_invalid_log_level_is_rejected() -> None:
    """An unknown log level fails fast rather than silently defaulting."""

    with pytest.raises(ValidationError):
        Settings(_env_file=None, LOG_LEVEL="VERBOSE")


def test_error_payload_shape_is_stable() -> None:
    """The failure envelope must stay identical for every error."""

    from app.utils.errors import ErrorCode

    payload = error_payload(
        code=ErrorCode.INTERNAL_SERVER_ERROR,
        message="An unexpected error occurred.",
    )

    assert payload == {
        "success": False,
        "error": {
            "code": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred.",
        },
    }


def test_app_error_subclasses_declare_code_and_status() -> None:
    """Domain errors map onto stable codes and status codes."""

    error = NotFoundError("Document not found.")

    assert isinstance(error, AppError)
    assert error.status_code == 404
    assert error.to_payload()["error"]["code"] == "NOT_FOUND"


def test_redact_secrets_masks_common_credential_shapes() -> None:
    """Logging must never emit passwords, API keys or JWTs."""

    log_line = (
        'login email="student@eduforge.ai" password=hunter2 '
        'api_key=sk-abc123 authorization: Bearer abc.def'
    )
    masked = redact_secrets(log_line)

    assert "hunter2" not in masked
    assert "sk-abc123" not in masked
    assert "abc.def" not in masked
    assert "student@eduforge.ai" in masked
    assert "REDACTED" in masked


def test_redact_secrets_masks_bare_jwt() -> None:
    """A JWT is masked even when it is not attached to a key."""

    token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NSJ9.abcdefghijkl"

    assert token not in redact_secrets(f"token received {token}")

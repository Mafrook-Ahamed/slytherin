"""Application error types and the JSON error envelope.

Clients always receive the same shape::

    {
        "success": false,
        "error": {
            "code": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred."
        }
    }

Internal details (stack traces, SQL, file paths, third-party payloads) stay in
the server log and are never serialised into a response.
"""

from __future__ import annotations

from enum import Enum
from typing import Any, Dict, Optional


class ErrorCode(str, Enum):
    """Stable, machine readable error identifiers for the Flutter client."""

    VALIDATION_ERROR = "VALIDATION_ERROR"
    BAD_REQUEST = "BAD_REQUEST"
    UNAUTHORIZED = "UNAUTHORIZED"
    FORBIDDEN = "FORBIDDEN"
    NOT_FOUND = "NOT_FOUND"
    CONFLICT = "CONFLICT"
    UNPROCESSABLE_ENTITY = "UNPROCESSABLE_ENTITY"
    RATE_LIMITED = "RATE_LIMITED"
    INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR"
    SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE"


#: Maps HTTP status codes onto the shared error codes.
STATUS_CODE_TO_ERROR_CODE: Dict[int, ErrorCode] = {
    400: ErrorCode.BAD_REQUEST,
    401: ErrorCode.UNAUTHORIZED,
    403: ErrorCode.FORBIDDEN,
    404: ErrorCode.NOT_FOUND,
    409: ErrorCode.CONFLICT,
    422: ErrorCode.VALIDATION_ERROR,
    429: ErrorCode.RATE_LIMITED,
    503: ErrorCode.SERVICE_UNAVAILABLE,
}


class AppError(Exception):
    """Base class for errors that are safe to surface to API clients.

    Raise these from services and repositories; the global handler in
    :mod:`app.main` turns them into the envelope above.
    """

    code: ErrorCode = ErrorCode.INTERNAL_SERVER_ERROR
    status_code: int = 500
    public_message: str = "An unexpected error occurred."

    def __init__(
        self,
        message: Optional[str] = None,
        *,
        details: Optional[Dict[str, Any]] = None,
    ) -> None:
        self.public_message = message or self.public_message
        self.details = details
        super().__init__(self.public_message)

    def to_payload(self) -> Dict[str, Any]:
        return error_payload(
            code=self.code,
            message=self.public_message,
            details=self.details,
        )


class BadRequestError(AppError):
    code = ErrorCode.BAD_REQUEST
    status_code = 400
    public_message = "The request could not be understood."


class UnauthorizedError(AppError):
    code = ErrorCode.UNAUTHORIZED
    status_code = 401
    public_message = "Authentication is required to access this resource."


class NotFoundError(AppError):
    code = ErrorCode.NOT_FOUND
    status_code = 404
    public_message = "The requested resource was not found."


class ConflictError(AppError):
    code = ErrorCode.CONFLICT
    status_code = 409
    public_message = "The request conflicts with the current state of the resource."


class ServiceUnavailableError(AppError):
    code = ErrorCode.SERVICE_UNAVAILABLE
    status_code = 503
    public_message = "The service is temporarily unavailable. Please try again."


def error_payload(
    code: ErrorCode,
    message: str,
    details: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """Build the consistent failure envelope.

    Args:
        code: Machine readable error code.
        message: Human readable, safe-to-display message.
        details: Optional extra context, e.g. field level validation errors.

    Returns:
        A JSON serialisable dictionary.
    """

    error: Dict[str, Any] = {"code": code.value, "message": message}
    if details:
        error["details"] = details
    return {"success": False, "error": error}

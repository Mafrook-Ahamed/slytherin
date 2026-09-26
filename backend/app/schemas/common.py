"""Shared response schemas.

Successful feature endpoints will use the ``APIResponse`` envelope::

    {"success": true, "data": {...}}

Service-level endpoints such as ``/`` and ``/api/v1/health`` intentionally
return their bare payload, because the Flutter client and monitoring tools
expect those exact shapes.
"""

from __future__ import annotations

from typing import Generic, TypeVar

from pydantic import BaseModel, ConfigDict, Field

from app.utils.errors import ErrorCode

T = TypeVar("T")


class ErrorDetail(BaseModel):
    """The ``error`` object of a failure response."""

    code: ErrorCode = Field(description="Stable, machine readable error identifier.")
    message: str = Field(description="Human readable, safe to display message.")
    details: dict | None = Field(
        default=None,
        description="Optional extra context, such as field level validation errors.",
    )


class ErrorResponse(BaseModel):
    """Envelope returned for every non-2xx response."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "success": False,
                "error": {
                    "code": "INTERNAL_SERVER_ERROR",
                    "message": "An unexpected error occurred.",
                },
            }
        }
    )

    success: bool = False
    error: ErrorDetail


class APIResponse(BaseModel, Generic[T]):
    """Envelope returned by successful feature endpoints."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "success": True,
                "data": {},
            }
        }
    )

    success: bool = True
    data: T


class RootResponse(BaseModel):
    """Payload of ``GET /``."""

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "message": "Welcome to EduForge AI API",
                "docs": "/docs",
            }
        }
    )

    message: str
    docs: str

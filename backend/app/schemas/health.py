"""Health check schemas."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class HealthResponse(BaseModel):
    """Payload of ``GET /api/v1/health``.

    The shape is fixed by the Flutter client's mock layer, so it is returned
    bare rather than wrapped in the standard success envelope.
    """

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "status": "ok",
                "service": "EduForge AI API",
                "version": "1.0.0",
            }
        }
    )

    status: str = Field(description="Service health state.", examples=["ok"])
    service: str = Field(description="Service name.", examples=["EduForge AI API"])
    version: str = Field(description="Semantic version of the API.", examples=["1.0.0"])

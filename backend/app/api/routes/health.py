"""Health check route.

Registered under the versioned prefix by :mod:`app.api.router`, which produces
``GET /api/v1/health``.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends

from app.schemas.health import HealthResponse
from app.services.health import HealthService, get_health_service

router = APIRouter(tags=["Health"])


@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Health check",
    operation_id="health_check",
    responses={
        200: {
            "description": "The service is running.",
            "content": {
                "application/json": {
                    "example": {
                        "status": "ok",
                        "service": "EduForge AI API",
                        "version": "1.0.0",
                    }
                }
            },
        }
    },
)
async def health_check(
    service: HealthService = Depends(get_health_service),
) -> HealthResponse:
    """Report service liveness.

    Args:
        service: Injected health service.

    Returns:
        The health payload for the running service.
    """

    return service.get_health()

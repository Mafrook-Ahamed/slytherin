"""Central versioned API router.

Every feature route is attached here, and ``app.main`` mounts this router once
at ``settings.api_prefix`` (``/api/v1``). Adding an endpoint therefore always
means: create ``app/api/routes/<feature>.py`` and register it below.
"""

from __future__ import annotations

from fastapi import APIRouter

from app.api.routes import health

#: Route modules that make up the v1 API surface.
ROUTERS: tuple[APIRouter, ...] = (
    health.router,
)

api_router = APIRouter()

for _router in ROUTERS:
    api_router.include_router(_router)

__all__ = ["api_router", "ROUTERS"]

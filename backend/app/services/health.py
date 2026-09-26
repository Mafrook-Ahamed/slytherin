"""Health service.

Liveness reporting lives in the service layer rather than directly in the route
so that later readiness checks (database, vector store, model provider) can be
added here without touching the API layer.
"""

from __future__ import annotations

from app.config import Settings, get_settings
from app.repositories.health import HealthRepository, ProcessHealthRepository
from app.schemas.health import HealthResponse


class HealthService:
    """Reports whether the API process is up and how it identifies itself."""

    def __init__(self, settings: Settings, repository: HealthRepository) -> None:
        self._settings = settings
        self._repository = repository

    def get_health(self) -> HealthResponse:
        """Return the current health payload.

        Returns:
            A :class:`HealthResponse` with ``status='ok'`` while the process is
            serving requests, or ``'unavailable'`` if the repository reports the
            process is not able to serve traffic.
        """

        status = "ok" if self._repository.is_alive() else "unavailable"
        return HealthResponse(
            status=status,
            service=self._settings.app_name,
            version=self._settings.app_version,
        )


def get_health_repository() -> HealthRepository:
    """FastAPI dependency providing the health repository.

    Declared as a dependency so tests can override it with a failing double via
    ``app.dependency_overrides``.
    """

    return ProcessHealthRepository(settings=get_settings())


def get_health_service(
    repository: HealthRepository | None = None,
) -> HealthService:
    """FastAPI dependency providing a :class:`HealthService`."""

    return HealthService(
        settings=get_settings(),
        repository=repository or get_health_repository(),
    )

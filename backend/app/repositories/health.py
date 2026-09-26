"""Repository layer for the health check.

The health endpoint answers from configuration, so it needs no data access. The
interface is declared anyway to establish the pattern every future repository
(auth, documents, quizzes) will follow, and to keep the service testable without
a database.
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from app.config import Settings


@runtime_checkable
class HealthRepository(Protocol):
    """Reports the health of the process itself."""

    def is_alive(self) -> bool:
        """Return ``True`` when the API process can serve requests."""
        ...


class ProcessHealthRepository:
    """Default implementation: the process is alive if this code runs."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def is_alive(self) -> bool:
        return True

    @property
    def service_name(self) -> str:
        return self._settings.app_name

    @property
    def version(self) -> str:
        return self._settings.app_version

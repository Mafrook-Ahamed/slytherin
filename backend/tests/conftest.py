"""Shared pytest fixtures.

Environment variables are set before ``app.main`` is imported so the settings
singleton is built with test-safe values and never picks up a developer's local
``.env`` file.
"""

from __future__ import annotations

import os
from collections.abc import Iterator
from typing import AsyncGenerator

os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault("DEBUG", "false")
os.environ.setdefault("LOG_LEVEL", "WARNING")
os.environ.setdefault("API_PREFIX", "/api/v1")
os.environ.setdefault("DOCS_ENABLED", "true")
os.environ.setdefault(
    "CORS_ORIGINS", "http://localhost:3000,http://10.0.2.2:8000"
)

from fastapi.testclient import TestClient  # noqa: E402  (must follow env setup)

from app.main import create_app  # noqa: E402


@pytest.fixture(scope="session")
def app() -> Iterator[object]:
    """Provide the FastAPI application used by the test session."""

    yield create_app()


@pytest.fixture(scope="session")
def client(app: object) -> Iterator[TestClient]:
    """Provide a synchronous test client for the application."""

    with TestClient(app, raise_server_exceptions=False) as test_client:
        yield testClient


@pytest.fixture
async def async_client(app: object) -> AsyncGenerator[object, None]:
    """Provide an async test client for tests that exercise ``await`` paths."""

    from httpx import ASGITransport, AsyncClient

    transport = ASGITransport(app=app, raise_app_exceptions=False)  # type: ignore[arg-type]
    async with AsyncClient(
        transport=transport, base_url="http://testserver"
    ) as async_test_client:
        yield async_test_client

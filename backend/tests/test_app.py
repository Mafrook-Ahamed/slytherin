"""Tests for the application root, documentation and error contract."""

from __future__ import annotations

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import BaseModel

from app.main import create_app


class SamplePayload(BaseModel):
    """Request model used to trigger a validation failure.

    Declared at module scope on purpose: this module uses
    ``from __future__ import annotations``, so annotations reach FastAPI as
    strings. A class defined inside a test function is not present in the module
    globals and FastAPI then reports a model level error instead of pointing at
    the offending field.
    """

    email: str


def test_root_returns_welcome_payload(client: TestClient) -> None:
    """``GET /`` must greet clients and point them at the docs."""

    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "message": "Welcome to EduForge AI API",
        "docs": "/docs",
    }


@pytest.mark.parametrize("path", ["/docs", "/redoc", "/api/v1/openapi.json"])
def test_documentation_endpoints_are_served(client: TestClient, path: str) -> None:
    """Swagger, ReDoc and the OpenAPI schema must be reachable."""

    response = client.get(path)

    assert response.status_code == 200


def test_openapi_metadata(client: TestClient) -> None:
    """Title, version and the Health tag must be configured."""

    schema = client.get("/api/v1/openapi.json").json()

    assert schema["info"]["title"] == "EduForge AI API"
    assert schema["info"]["version"] == "1.0.0"
    assert "Health" in {tag["name"] for tag in schema["tags"]}


def test_unknown_path_uses_error_envelope(client: TestClient) -> None:
    """A 404 must follow the shared failure contract, not FastAPI's default."""

    response = client.get("/api/v1/does-not-exist")

    assert response.status_code == 404
    body = response.json()
    assert body["success"] is False
    assert body["error"]["code"] == "NOT_FOUND"
    assert "message" in body["error"]
    assert "traceback" not in response.text.lower()


def test_method_not_allowed_uses_error_envelope(client: TestClient) -> None:
    """A wrong method must also return the shared failure contract."""

    response = client.post("/api/v1/health")

    assert response.status_code == 405
    assert response.json()["error"]["code"] == "BAD_REQUEST"


def test_unexpected_error_is_not_leaked(client: TestClient) -> None:
    """An unhandled exception must produce a generic 500 with no details."""

    test_app: FastAPI = create_app()

    @test_app.get("/api/v1/_test/boom")
    async def boom() -> None:
        raise RuntimeError("database password=super-secret-token-value")

    with TestClient(test_app, raise_server_exceptions=False) as error_client:
        response = error_client.get("/api/v1/_test/boom")

    assert response.status_code == 500
    body = response.json()
    assert body["success"] is False
    assert body["error"]["code"] == "INTERNAL_SERVER_ERROR"
    assert body["error"]["message"] == "An unexpected error occurred."
    assert "super-secret-token-value" not in response.text


def test_application_error_uses_declared_code(client: TestClient) -> None:
    """Errors raised from a service keep their status code and error code."""

    from app.utils.errors import NotFoundError

    test_app: FastAPI = create_app()

    @test_app.get("/api/v1/_test/missing")
    async def missing() -> None:
        raise NotFoundError("Document not found.")

    with TestClient(test_app, raise_server_exceptions=False) as error_client:
        response = error_client.get("/api/v1/_test/missing")

    assert response.status_code == 404
    body = response.json()
    assert body["error"]["code"] == "NOT_FOUND"
    assert body["error"]["message"] == "Document not found."


def test_validation_errors_keep_field_details(client: TestClient) -> None:
    """Validation failures must report which fields were wrong."""

    test_app: FastAPI = create_app()

    @test_app.post("/api/v1/_test/validate")
    async def validate(payload: SamplePayload) -> dict[str, str]:
        return {"email": payload.email}

    with TestClient(test_app, raise_server_exceptions=False) as error_client:
        response = error_client.post("/api/v1/_test/validate", json={"email": 123})

    assert response.status_code == 422
    body = response.json()
    assert body["success"] is False
    assert body["error"]["code"] == "VALIDATION_ERROR"
    details = body["error"]["details"]["errors"]
    assert details[0]["location"][-1] == "email"
    assert "message" in details[0]
    assert "type" in details[0]


def test_cors_preflight_from_flutter_origin(client: TestClient) -> None:
    """A Flutter dev origin must pass the CORS preflight check."""

    response = client.options(
        "/api/v1/health",
        headers={
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "GET",
        },
    )

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "http://localhost:3000"


def test_cors_preflight_from_unknown_origin(client: TestClient) -> None:
    """An unlisted origin must not be reflected back to the client."""

    response = client.options(
        "/api/v1/health",
        headers={
            "Origin": "https://evil.example.com",
            "Access-Control-Request-Method": "GET",
        },
    )

    assert "access-control-allow-origin" not in response.headers

"""Health endpoint tests."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_health_returns_200(client: TestClient) -> None:
    """The health endpoint must answer with HTTP 200 while the service runs."""

    response = client.get("/api/v1/health")

    assert response.status_code == 200


def test_health_returns_json(client: TestClient) -> None:
    """The health endpoint must return a JSON content type."""

    response = client.get("/api/v1/health")

    assert response.headers["content-type"].startswith("application/json")


def test_health_payload_is_correct(client: TestClient) -> None:
    """The health payload must match the contract the Flutter client expects."""

    response = client.get("/api/v1/health")
    body = response.json()

    assert body["status"] == "ok"
    assert body["service"] == "EduForge AI API"
    assert body["version"] == "1.0.0"


def test_health_payload_has_exactly_three_keys(client: TestClient) -> None:
    """The response is a bare payload, not wrapped in the success envelope."""

    body = client.get("/api/v1/health").json()

    assert set(body.keys()) == {"status", "service", "version"}
    assert "success" not in body
    assert "data" not in body


def test_health_is_documented(client: TestClient) -> None:
    """The health route must appear in the OpenAPI schema under its tag."""

    schema = client.get("/api/v1/openapi.json").json()

    assert "/api/v1/health" in schema["paths"]
    assert schema["paths"]["/api/v1/health"]["get"]["tags"] == ["Health"]

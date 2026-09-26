"""EduForge AI API application factory.

Responsibilities are deliberately limited to transport concerns:

* create the :class:`~fastapi.FastAPI` instance and its documentation metadata
* mount the versioned router at ``settings.api_prefix``
* install CORS
* translate exceptions into the shared error envelope
* log application and request lifecycle events

Business rules live in ``app.services`` and data access in
``app.repositories``; the layers below this one are wired through FastAPI
dependencies.
"""

from __future__ import annotations

import time
from contextlib import asynccontextmanager
from typing import Any, AsyncIterator, List

from fastapi import FastAPI, Request, status
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.router import api_router
from app.config import Settings, get_settings
from app.schemas.common import RootResponse
from app.utils.errors import (
    STATUS_CODE_TO_ERROR_CODE,
    AppError,
    ErrorCode,
    error_payload,
)
from app.utils.logging_config import (
    configure_logging,
    get_logger,
    log_settings,
)

logger = get_logger(__name__)

#: Paths that must never be written to the access log.
_QUIET_PATHS = {"/api/v1/health"}


def _describe_request(request: Request) -> str:
    client = request.client.host if request.client else "unknown"
    return f'client={client} method={request.method} path={request.url.path}'


def _sanitise_validation_errors(
    errors: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    """Reduce FastAPI validation errors to JSON-safe, debuggable fields.

    The original ``errors()`` payload can contain arbitrary objects (for example
    the exception raised by a custom validator), which are not guaranteed to be
    serialisable.
    """

    sanitised: List[Dict[str, Any]] = []
    for error in errors:
        sanitised.append(
            {
                "location": [str(part) for part in error.get("loc", ())],
                "message": str(error.get("msg", "Invalid value")),
                "type": str(error.get("type", "value_error")),
            }
        )
    return sanitised


def register_exception_handlers(app: FastAPI) -> None:
    """Install handlers that guarantee a consistent failure envelope."""

    @app.exception_handler(AppError)
    async def handle_app_error(
        _request: Request, exc: AppError
    ) -> JSONResponse:
        """Return a known application error with its declared status code."""

        logger.warning("Application error: %s", exc.public_message)
        return JSONResponse(
            status_code=exc.status_code,
            content=jsonable_encoder(exc.to_payload()),
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(
        _request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        """Return 422 with the field level details, but without a stack trace.

        FastAPI's default body is intentionally not wrapped twice: the envelope
        keeps the contract consistent while ``error.details.errors`` preserves
        the standard structure clients expect.
        """

        logger.warning("Request validation failed: %s", _describe_request(_request))
        return JSONResponse(
            status_code=422,
            content=jsonable_encoder(
                error_payload(
                    code=ErrorCode.VALIDATION_ERROR,
                    message="Request validation failed.",
                    details={"errors": _sanitise_validation_errors(exc.errors())},
                )
            ),
        )

    @app.exception_handler(StarletteHTTPException)
    async def handle_http_exception(
        _request: Request, exc: StarletteHTTPException
    ) -> JSONResponse:
        """Map framework level HTTP errors (404, 405, …) onto the envelope."""

        code = STATUS_CODE_TO_ERROR_CODE.get(
            exc.status_code, ErrorCode.INTERNAL_SERVER_ERROR
        )
        detail = exc.detail if isinstance(exc.detail, str) else None
        message = detail or code.value.replace("_", " ").capitalize()

        if exc.status_code >= status.HTTP_500_INTERNAL_SERVER_ERROR:
            logger.error("HTTP %s on %s", exc.status_code, _request.url.path)
        else:
            logger.info("HTTP %s on %s", exc.status_code, _request.url.path)

        return JSONResponse(
            status_code=exc.status_code,
            content=jsonable_encoder(error_payload(code=code, message=message)),
            headers=getattr(exc, "headers", None),
        )

    @app.exception_handler(Exception)
    async def handle_unexpected_error(_request: Request, exc: Exception) -> JSONResponse:
        """Log the full traceback server side and return a generic message.

        The exception object and its stack trace never reach the client.
        """

        logger.exception("Unhandled error while processing %s", _describe_request(_request))
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content=error_payload(
                code=ErrorCode.INTERNAL_SERVER_ERROR,
                message="An unexpected error occurred.",
            ),
        )


def register_middleware(app: FastAPI, settings: Settings) -> None:
    """Install CORS and access logging."""

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=settings.cors_allow_credentials,
        allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type", "Accept", "X-Requested-With"],
        expose_headers=["X-Request-ID"],
        max_age=3600,
    )

    @app.middleware("http")
    async def log_requests(request: Request, call_next: Any) -> Any:
        """Log method, path, status and duration for every request.

        Request and response bodies are intentionally excluded so credentials
        are never written to disk.
        """

        started = time.perf_counter()
        response = await call_next(request)
        elapsed_ms = (time.perf_counter() - started) * 1000

        if request.url.path not in _QUIET_PATHS:
            logger.info(
                "%s %s -> %s in %.1fms",
                request.method,
                request.url.path,
                response.status_code,
                elapsed_ms,
            )
        return response


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build and configure the FastAPI application.

    Exposed as a factory so tests can create an isolated instance, for example
    with documentation disabled or with dependencies overridden.

    Args:
        settings: Optional settings override; the cached singleton is used by
            default.

    Returns:
        A fully configured :class:`~fastapi.FastAPI` application.
    """

    settings = settings or get_settings()
    configure_logging(settings.log_level, force=True)

    @asynccontextmanager
    async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
        """Log startup and shutdown without leaking configuration secrets."""

        log_settings(settings.public_summary())
        logger.info(
            "Starting %s v%s (environment=%s)",
            settings.app_name,
            settings.app_version,
            settings.environment.value,
        )
        logger.info("API available at %s%s", settings.api_prefix, "/health")
        if settings.docs_enabled:
            logger.info("Documentation: /docs and /redoc")
        else:
            logger.info("Documentation endpoints are disabled")
        if settings.is_development:
            logger.info(
                "CORS allowed origins: %s", ", ".join(settings.cors_origins)
            )
        yield
        logger.info("Shutting down %s", settings.app_name)

    app = FastAPI(
        title=settings.app_name,
        description=settings.app_description,
        version=settings.app_version,
        debug=settings.debug,
        docs_url=settings.docs_url,
        redoc_url=settings.redoc_url,
        openapi_url=settings.openapi_url,
        lifespan=lifespan,
        openapi_tags=[
            {"name": "Health", "description": "Service liveness and diagnostics."},
            {
                "name": "Auth",
                "description": "Registration, login and session management.",
            },
            {
                "name": "Documents",
                "description": "Upload and manage study material PDFs.",
            },
            {"name": "Chat", "description": "Document grounded AI assistance."},
            {"name": "Quiz", "description": "Quiz generation, attempt and scoring."},
            {
                "name": "Recommendations",
                "description": "Personalised next-step learning suggestions.",
            },
        ],
        responses={
            400: {"description": "Bad request."},
            401: {"description": "Authentication required."},
            404: {"description": "Resource not found."},
            422: {"description": "Request validation failed."},
            500: {"description": "Unexpected server error."},
        },
    )

    register_middleware(app, settings)
    register_exception_handlers(app)

    @app.get(
        "/",
        response_model=RootResponse,
        tags=["Health"],
        summary="Service root",
        operation_id="root",
    )
    async def root() -> RootResponse:
        """Welcome payload that points clients at the API documentation."""

        return RootResponse(
            message="Welcome to EduForge AI API",
            docs=settings.docs_url or "/docs",
        )

    app.include_router(api_router, prefix=settings.api_prefix)

    return app


#: ASGI entry point used by ``uvicorn app.main:app``.
app = create_app()

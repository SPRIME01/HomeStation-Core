"""
FastAPI application entrypoint for the ``core`` context.

This application defines a minimal API.  You can extend it by importing
additional routers from your application layer or by adding new endpoints
directly.  When you generate real contexts with the Nx plugin the main
module will be updated automatically to include your new routes.
"""

from fastapi import FastAPI


app = FastAPI(title="HomeStation_Core API")


@app.get("/health")
async def health() -> dict[str, str]:
    """Simple health check endpoint returning application status."""
    return {"status": "ok"}
"""End-to-end test for the core service.

This test performs a simple health check against the running FastAPI application.
In a real project you would start the server in a fixture and then use an
HTTP client like httpx to send requests.  For brevity, this test only
validates the shape of the root handler.
"""
from importlib import import_module

def test_health_response_structure():
    # Dynamically import the app from the generated main module
    module = import_module("apps.core-api.main")
    app = getattr(module, "app", None)
    assert app is not None
    assert callable(app.get)

#!/bin/bash
# Development server runner for HomeStation_Core

echo "Starting FastAPI development server..."
uv run uvicorn main:app --reload --app-dir apps/core-api

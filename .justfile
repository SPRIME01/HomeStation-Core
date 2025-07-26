# Justfile for HomeStation_Core

set dotenv-load

# Start the FastAPI development server
dev:
    cd apps/core-api && uv run uvicorn main:app --reload --host 0.0.0.0

# Run Ruff linter and MyPy type checker on all code
lint:
    uv run ruff check libs apps tools
    uv run mypy libs apps tools

# Run the automated test suite
test:
    uv run pytest libs apps tools

# Format all Python code using Ruff
format:
    uv run ruff format libs apps tools

# Check import boundaries and ensure hexagonal layering rules
validate:
    uv run python tools/scripts/validate_hexagon.py

# Build a Docker image for the default context's microservice
build-service:
    pnpm nx run core-svc:docker

# Train an ML model for the default context's microservice
train:
    pnpm nx run core-svc:train

# Promote the trained model to production for the default context's microservice
promote:
    pnpm nx run core-svc:promote

# Deploy the default context's microservice
deploy:
    pnpm nx run core-svc:deploy


# Generate project documentation (stub)
docs:
    uv run python tools/scripts/generate_docs.py

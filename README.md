# HomeStation_Core

Welcome to your freshly minted Nx hexagonal monorepo!  This project was
generated from the [cookiecutter‑nx‑hexagon](../) template.  It provides a
ready‑to‑run FastAPI application and a set of libraries following a
hexagonal architecture pattern (domain → application → infrastructure).  All
tooling for linting, formatting, testing and validating the layering rules is
preconfigured.

## Project Structure

```text
HomeStation_Core/
├── apps/
│   └── core-api/         # FastAPI application entrypoint
├── libs/
│   ├── core-domain/       # Domain entities, ports and events
│   ├── core-application/  # Use cases, services and routes
│   └── core-infrastructure/ # Concrete adapters and DI wiring
├── tools/
│   └── scripts/               # Helper scripts (validate, docs)
├── .justfile                  # Task runner definitions
├── pyproject.toml             # Python dependencies and tool configuration
├── package.json               # Node/Nx configuration
├── pnpm-workspace.yaml        # pnpm workspace definition
├── nx.json                    # Nx workspace configuration
├── .python-version            # Python version specification
├── .env                       # Environment variables (example)
└── .github/workflows/ci.yaml  # GitHub Actions workflow (optional)
```

## Running the API

Install dependencies and start the development server:

```bash
# Install Node.js dependencies
pnpm install

# Install Python dependencies with uv
uv sync --all-extras

# Start the development server
uv run uvicorn main:app --reload --app-dir apps/core-api
```

The API will be available at `http://localhost:8000/`.  A basic health
endpoint is defined in `apps/core-api/main.py`.

## Linting, Formatting and Tests

Run the following commands from the repository root (after activating the uv environment):

* `uv run ruff check libs apps tools` – static analysis with Ruff
* `uv run mypy libs apps tools` – type checking with MyPy
* `uv run ruff format libs apps tools` – fix formatting using Ruff
* `uv run pytest -q` – run all Python tests with PyTest
* `uv run python tools/scripts/validate_hexagon.py` – ensure hexagonal layering rules are respected

## Extending This Project

The included libraries under `libs/` are only a starting point.  Add
aggregates, ports and use cases with the custom Nx plugin provided in this
repository (see the `hexagon_plugin` package).  Each generator will
produce correctly wired files in the appropriate layers.  Consult the
template’s README for details on how to use the generators.

## Continuous Integration

If you answered “yes” to the `enable_github_ci` prompt, this project comes
with a GitHub Actions workflow under `.github/workflows/ci.yaml`.  It
installs dependencies, runs lint, type check and test jobs and enforces the
layering rules on every push and pull request.  Secrets such as `UV_TOKEN`
can be configured in your repository settings.

# Technology Stack & Build System

## Toolchain Versions (authoritative)
```yaml
engines:
  node: ">=18.0.0"
  pnpm: ">=8.0.0"
  python: ">=3.12"
  uv: ">=0.1.0"
  nx: ">=16.0.0"
  just: ">=1.10.0"
  docker: ">=24.0.0"
platforms:
  os: ["macOS", "Linux", "Windows (WSL2)"]
```

## Languages
- **Python 3.12+** for backend services, machine learning and scripts.
- **TypeScript/ESM** for web and mobile front‑ends and for Node‑based backend components.

## Monorepo, Build & Tasks
- This repository is an Nx monorepo. Nx orchestrates builds, runs dependency graphs and caches results.
- **Just** is the canonical task runner. Each Nx target has a corresponding just recipe; use Just whenever possible (e.g. `just test` runs `nx test` for the affected projects).
- No legacy build systems are used; if one appears, an ADR must authorise it and define its deprecation path.

## Package Management
- **Node:** pnpm is the only supported package manager. Use `pnpm install` to install dependencies. Do not use npm except during initial CI bootstrap.
- **Python:** use `uv` for dependency management and virtual environments. Invoke `uv sync` to install dependencies into `.venv`. Do not use pip outside of `uv` unless specified.
- A lockfile is required for both ecosystems (`pnpm-lock.yaml` and `uv.lock`). Commit them to version control.

## Frameworks & Libraries
- **Frontend:** SvelteKit with Vite is used for the web application. Use Svelte store for state management and Tailwind for styling.
- **Backend:** FastAPI is used for HTTP APIs. Business logic is organised into services and repositories.
- **AI/ML:** This project uses pgvector and open-source models for embedding and vector search. Model lifecycle management is performed via Python scripts in `apps/ml`.

## Database & Storage
- **Primary database:** PostgreSQL with the pgvector extension, provisioned via Supabase. Migrations are written with Alembic (Python) and executed via `just db-migrate`.
- **ORM/data access:** Use SQLModel in Python and Prisma in TypeScript for type‑safe database access. Maintain versioned schema files in `libs/shared/db`.

## Infrastructure & Operations
- **Containers:** All deployable services build Docker images from the root `Dockerfile`. Use `docker buildx bake` for multi‑arch images.
- **Orchestration:** Kubernetes manages service deployments. Helm charts live in `infrastructure/helm` and define deployments per environment.
- **IaC:** Terraform code lives in `infrastructure/terraform` and provisions cloud resources. Pulumi is reserved for future infrastructure if needed.
- **Observability:** Use Prometheus for metrics, Loki for logs and Jaeger for tracing. Expose metrics on `/metrics` endpoints in services.
- **Secrets:** Secrets are stored in HashiCorp Vault and injected via environment variables at runtime. Do not commit secrets to git.

## Development Environment
- Supported operating systems: macOS, Linux and Windows 11 via WSL2. Native Windows is not officially supported for container builds.
- Use bash or zsh shells. PowerShell is supported within WSL2.
- Install pre‑commit hooks with `just setup` to enforce code formatting and linting.
- Recommended VS Code extensions: Pyright, Svelte for VS Code, ESLint, Tailwind CSS IntelliSense and Prettier.

## Common Commands
### Setup & Env
```bash
just setup            # installs dependencies and hooks
uv sync               # install Python dependencies into .venv
nx graph              # generate dependency graph
```

### Development
```bash
just dev              # concurrently run backend and frontend apps
nx serve web          # serve the web app
nx build api          # build the API project
```

### Quality & Tests
```bash
just lint             # run eslint, stylelint, flake8 and mypy
nx affected --target=lint  # lint only affected projects
just test             # run Python and TypeScript unit tests
nx affected --target=test  # test only affected projects
```

### Workspace & Codegen
```bash
just app NAME=chat    # scaffold a new app called chat via Nx generator
just lib NAME=utils   # scaffold a new shared library
```

### Services & Ops
```bash
just containerize PROJECT=api  # build and tag Docker image for api
just k8s-deploy PROJECT=api    # deploy api to Kubernetes using Helm
```

### Data & ML
```bash
just supabase-up      # start Supabase locally for dev
just train            # train machine learning models
just evaluate         # run evaluation suite on trained models
```

## Build Conventions
- Projects are tagged using Nx conventions: `context:<name>`, `layer:<domain|application|infrastructure>`, `type:<service|model|e2e>`, `deployable:<true|false>`.
- Services and apps are suffixed with `-svc` when they expose an API (e.g. `auth-svc`). Libraries live under `libs/<scope>/<name>` and expose their API through an `index.ts` or `__init__.py`.
- The monorepo directory structure follows `apps/`, `libs/`, `tools/`, `infrastructure/`, `scripts/` and `docs/` at the root.

## Environment Variables
- Define all environment variables in `.env` and commit a safe default template to `.env.template`. The `.env` file is never committed.
- The Python backend uses the `python-dotenv` package to load variables. The Node/TypeScript side loads variables via `@org/config`.
- When adding a new variable, update both `.env` and `.env.template` and document it in `engineering.md`.

## Compatibility Matrix

| Area   | Supported           | Notes |
|-------:|----------------------|:-----|
| OS     | macOS, Linux, WSL2  | Native Windows not supported for container builds |
| Node   | ≥ 18                | ESM only |
| Python | ≥ 3.12              | Dependencies installed into `.venv` |
| Docker | ≥ 24                | Use Buildx for multi‑arch images |

## Code Generation & Scaffolding
- Prefer Nx and Just generators for creating new apps and libraries. Use `just app NAME=<name>` and `just lib NAME=<name>` to scaffold new components.
- Use cookiecutter templates only when Nx does not provide an equivalent generator.
- **Do not hand‑roll scaffolds**; ensure the resulting project adheres to naming and tagging conventions.

## Testing & Quality Gates
- Unit tests are written with PyTest and Vitest. Integration tests use FastAPI’s TestClient and Playwright. End‑to‑end tests use Cypress.
- The CI pipeline runs affected tests via `nx affected --target=test` and enforces coverage thresholds (≥ 90 % for unit tests).
- Linting and type checking are mandatory; the build fails on any errors.

## Security & Secrets Handling
- Secrets are pulled from Vault and exposed as environment variables. Never hardcode secrets or tokens.
- Logging must scrub PII and secrets; follow guidance in `.github/instructions/security.md`.
- Apply least‑privilege principles to service accounts, roles and IAM policies.

## Performance & SLOs
- All API endpoints must meet p95 latency of ≤ 250 ms under the target load.
- Data ingestion pipelines must sustain at least 100 rps with CPU usage < 70 % on baseline hardware.
- Model inference endpoints must respond within 500 ms p95.

## Overrides (Repo‑specific)
- This repository deviates from the organisation default by using FastAPI instead of Express for API services due to Python‑centric ML requirements. Document this decision in an ADR.

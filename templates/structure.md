# Project Structure & Organisation

## Monorepo Layout (authoritative)
This repository is organised as an Nx monorepo. The top‑level tree looks like this:

```text
<repo-root>/
├─ apps/               # Runtime applications (deployable services and front‑ends)
│  ├─ api/             # FastAPI service exposing HTTP endpoints
│  ├─ web/             # SvelteKit SSR web application
│  └─ ml/              # Machine learning pipeline and model serving
├─ libs/               # Shared and platform‑specific libraries
│  ├─ shared/          # Cross‑platform utilities (e.g. types, data‑access, validation)
│  ├─ web/             # Web‑only feature libraries
│  ├─ mobile/          # Mobile‑only feature libraries (if used)
│  └─ api/             # Common API logic (e.g. authentication, error handling)
├─ tools/              # Generators and custom Nx executors
├─ infrastructure/     # IaC (Pulumi), Kubernetes manifests, Helm charts, and Ansible playbooks
├─ scripts/            # Development utilities (setup, migrations, data seeding)
├─ docs/               # Project documentation (architecture, decision records)
└─ .github/instructions/ # Steering documents (product.md, tech.md, structure.md, etc.)
```

## Applications (`apps/`) — Pattern
Each application in `apps/` follows a consistent internal structure:

- **api/** — FastAPI service
  - `src/main.py` — application entry point and ASGI setup.
  - `src/api/` — API route definitions and request/response models.
  - `src/core/` — business logic and domain services.
  - `src/models/` — Pydantic models and database schemas.
  - `src/config.py` — configuration loading and validation.
- **web/** — SvelteKit web application
  - `src/routes/` — page routes and API endpoints.
  - `src/lib/` — reusable components and utilities.
  - `src/stores/` — Svelte stores for state management.
  - `src/services/` — API clients and data‑access functions.
  - `src/config.ts` — application configuration.
- **ml/** — ML pipeline and inference service
  - `src/train.py` — training pipeline entry point.
  - `src/evaluate.py` — model evaluation scripts.
  - `src/serve.py` — inference server entry point.
  - `src/data/` — data loaders and dataset definitions.

## Shared Libraries (`libs/`) — Pattern
Libraries in `libs/` provide reusable code across applications:

- **shared/** — Cross‑platform utilities
  - `types/` — shared type definitions.
  - `data-access/` — database clients (e.g. SQLModel, Prisma) and query helpers.
  - `utils/` — generic utilities (logging, validation, error wrappers).
  - Each library exports its API via an `index.ts` (TypeScript) or `__init__.py` (Python).
- **web/** — Web‑specific feature libraries
  - `feature-<name>/` — each feature encapsulates UI components, state management and data hooks.
  - `testing/` — test utilities for web features.
- **mobile/** — Mobile‑specific feature libraries (if used).
- **api/** — Common API code used by server applications; includes error classes, response helpers and authentication logic.

Libraries may depend on `shared` and platform siblings. Avoid circular dependencies between libraries. Public APIs must be well defined and documented.

## Feature Module Pattern
Feature libraries are grouped by platform under `libs/web/feature-*` and `libs/mobile/feature-*`. Each feature library contains:
- Components or screens implementing the feature’s UI.
- State management (e.g. stores) scoped to the feature.
- Data hooks or API clients specific to the feature.
- Co‑located tests (`*.spec.ts`, `*.test.ts`).

Features rely on types from `libs/shared/types` and data‑access clients from `libs/shared/data-access`. Do not directly import from other features.

## Import Path Conventions
Import paths use an organisation‑prefixed alias defined in `tsconfig.json` and `pyproject.toml`. Examples:

```ts
import { User } from '@org/shared/types';
import { db } from '@org/shared/data-access';
import { ContactService } from '@org/web/feature-contacts';
// INVALID: do not use deep relative imports across modules
// import { User } from '../../../libs/shared/types/src/user';
```

## Nx (Build System) Targets Baseline
Each project (app or library) defines a standard set of Nx targets:
- **lint** — run linters and formatters.
- **typecheck** — run type checkers (e.g. mypy, tsc).
- **test** — run unit tests.
- **build** — produce a production build (if applicable).
- **serve** — run a development server (apps only).
- **container** — build a container image (deployable services).
- Custom targets (e.g. `migrate`, `seed`, `deploy`) are defined in the project’s `project.json` when necessary.

Affected targets are executed in CI using `nx affected --target=<target>` to run tasks only on projects impacted by a given change.

## Naming & Tagging Conventions
- **Directory names:** use kebab‑case (e.g. `user-service`, `feature-chat`).
- **Python modules:** use snake_case. **TypeScript classes/components:** use PascalCase for exported React/Svelte components.
- **Nx tags:** annotate projects with context, layer, type and deployable flags (e.g. `context:auth`, `layer:application`, `type:service`, `deployable:true`).

## Configuration & Env Files
- Root configuration: `nx.json`, `package.json`, `pyproject.toml`, `.prettierrc`, `.eslintrc`, `justfile`, lockfiles (`pnpm-lock.yaml`, `uv.lock`).
- Project configuration: `project.json` inside each app or library, along with framework‑specific configs (e.g. `vite.config.ts`, `fastapi-config.py`, `Dockerfile`).
- Environment variables: `.env` (not committed) and `.env.template` (committed). When adding new variables, update both files and document them in `engineering.md`.

## File‑Organisation Rules (Do/Don’t)
- **Do** separate business logic (`core/`) from API handlers (`api/`) and UI components.
- **Do** keep models/schemas in `models/` or `types/` directories.
- **Do** place platform‑specific code in platform folders (`apps/web`, `libs/web`).
- **Do** co‑locate test files with the code they test using `*.spec.*` or `*.test.*` naming.
- **Don’t** duplicate utilities across applications; place them in `libs/shared/utils` and import them.
- **Don’t** import outside of a module’s public API; use the alias names instead of deep relative paths.

## Dependency Boundaries
- Applications may depend on shared libraries and on platform‑specific features; they should avoid direct dependencies on other applications.
- Shared libraries minimise dependencies on other libraries; if needed, explicitly declare them in `project.json` and avoid cycles.
- External packages are defined in each project’s manifest (`package.json` or `pyproject.toml`) and should be added only when necessary.

## Examples (non‑authoritative)

Standard library layout:

```text
libs/shared/types/
├─ src/
│  ├─ user.ts
│  └─ index.ts      # exports public API
├─ project.json     # Nx project configuration
└─ README.md        # library description

libs/web/feature-contacts/
├─ src/
│  ├─ components/ContactsPage.svelte
│  ├─ stores/contactsStore.ts
│  ├─ api/contactsApi.ts
│  └─ index.ts      # exports feature API
├─ project.json
└─ README.md
```

Valid imports:

```ts
import { Contact } from '@org/shared/types';
import { fetchContacts } from '@org/web/feature-contacts';
```

Invalid import:

```ts
// Do not reach into file system paths outside of module boundaries
import { Contact } from '../../../../../libs/shared/types/src/user';
```

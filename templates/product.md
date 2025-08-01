# Product Overview
Provide a concise statement of what the product is and the core outcome it delivers for users in one or two sentences. Keep this evergreen and independent of specific implementation details.

## Target Users & Jobs‑to‑be‑Done
- **Primary Persona 1** — key jobs: …; pains addressed: …; gains expected: …
- **Primary Persona 2** — key jobs: …; pains addressed: …; gains expected: …
- **Secondary Personas** — mention only if they influence major priorities.

## Core Value Proposition
- We optimise for: **e.g. time‑to‑insight < 60 seconds**, **edge reliability**.
- We trade off: **e.g. non‑critical customisations**, **legacy browser support**.

## Key Capabilities
### Must‑haves
- [M1] First key capability with a testable outcome.
- [M2] Second key capability.
- [M3] Third key capability.

### Nice‑to‑haves
- [N1] Optional capability.
- [N2] Optional capability.

## Platforms & Interfaces
- **Web:** primary user experience (e.g. responsive SSR/SPA, PWA requirements).
- **Mobile:** native, Expo, or not supported; note offline support expectations.
- **API/CLI:** describe surface area, stability guarantees and versioning policy.
- **Integrations:** identity providers, payment gateways, data stores, observability tools, model/inference backends.

## Constraints & Guardrails
- **Security:** authentication and authorisation model; encryption in transit and at rest; secrets management.
- **Privacy/Data:** PII categories handled; retention and deletion/export policies.
- **Performance/SLOs:** state p95 latency thresholds and throughput targets for critical paths.
- **Availability/Recovery:** e.g. 99.9 % uptime; RTO of 30 minutes; RPO of 5 minutes.
- **Compliance/Legal:** licensing constraints; open‑source usage policy; third‑party service boundaries.
- **Architecture guardrails:** e.g. prefer Just over ad‑hoc scripts; use generators/scaffolding; enforce hexagonal boundaries.

## Non‑Goals (Out of Scope)
- We will not support X because Y.
- We will not implement Z before milestone N.

## Success Metrics
### Leading (adoption & usability)
- TTFHW (time to first happy workflow) ≤ X minutes.
- Weekly active users ≥ Y within Z weeks of GA.
- Task success rate ≥ P % for top three flows.

### Operational (reliability & performance)
- p95 latency ≤ X ms for endpoint Y.
- Error budget: ≤ Q % per quarter.
- Mean time to recovery (MTTR) ≤ R minutes.

### Lagging (business)
- Revenue, retention or conversion targets with specified horizon.

## Release Themes & Priorities
1. **Theme A (Priority 1)** — rationale in one sentence.
2. **Theme B (Priority 2)** — rationale in one sentence.
3. **Theme C (Priority 3)** — rationale in one sentence.

## Decision Heuristics
- **Prefer** standardised generators (Nx/Just/cookiecutter) over hand‑rolled scaffolding.
- **Prefer** API compatibility with widely adopted patterns (e.g. OpenAI‑style endpoints) when in doubt.
- **Prefer** portability (Docker/Kubernetes) over vendor‑specific features unless a cost–benefit analysis justifies the lock‑in.
- **Do not** leak PII into logs, traces or telemetry; scrub at source.
- **Do not** introduce technologies or dependencies that circumvent the CI lint/spec gates.

## Risks & Mitigations
- **Risk:** Identify a top technical or product risk — **Mitigation:** Summarise how it will be mitigated (e.g. proof of concept, phased rollout).
- **Risk:** Identify another risk — **Mitigation:** Summarise mitigation.

## References
- `.github/instructions/engineering.md` — engineering guardrails.
- `.github/instructions/security.md` — security requirements.
- `.github/instructions/data.md` — data governance requirements.
- `.github/instructions/ux.md` — UX guidelines.
- `requirements.md`, `design.md`, `tasks.md` — spec pack documents.
- `Justfile` — run `just help` to discover commands and recipes.
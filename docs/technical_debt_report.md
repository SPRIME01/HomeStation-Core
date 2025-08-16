Reviewing infrastructure Pulumi code and Kubernetes YAML for configuration and security issues. Assessing scripts directory for scripting debt. Evaluating test presence and patterns. Reviewing documentation directory for coverage and fragmentation. Searching for TODO and FIXME markers for latent debt. Synthesizing AI agent compatibility and compiling full prioritized technical debt report. ## Technical Debt Assessment (Holistic, Prioritized)

### Legend
Severity: Critical / High / Medium / Low
Impact Axes: Sec (Security), Rel (Reliability), DX (Dev Velocity), AI (AI-agent clarity), Ops (Operational cost)
Effort: S (≤2h), M (≤1 day), L (multi-day)

---

## 1. Dependency Debt

| Issue | Evidence | Severity | Impact | Notes & Remediation |
|-------|----------|----------|--------|---------------------|
| Jest 30 + ts-jest 29 mismatch | root package.json (`"jest": "^30.0.5"`, `"ts-jest": "^29.4.0"`) | High | Rel, DX, AI | Likely incompatibilities (ts-jest historically lags). Pin Jest to 29 or upgrade to `babel-jest` + SWC. |
| Mixed version pinning styles | Exact for Nx core (`21.3.10`) vs carets for others (`^8.38.0`) | Medium | Rel, DX | Adopt single policy: pin & use Renovate bot for controlled upgrades. |
| Out-of-scope runtime deps in root | Only `jsonwebtoken` + `@types/jsonwebtoken` at root (infra/dev-heavy repo) | Low | DX | Consider moving runtime-only use into a dedicated tool package or script isolation. |
| Outdated FastAPI / uvicorn pinned arbitrarily | Generated `requirements.txt` (fastapi==0.104.1, uvicorn==0.24.0) | Medium | Sec, Rel | Align with latest stable; add a template dependency management strategy (e.g. `uv` or constraints file). |
| Python service generator missing dependency parity | Generated `main.py` doesn’t import FastAPI (still installs it) | Low | DX, AI | Either scaffold FastAPI app or remove large unused deps (bundle-size/time waste). |
| Node service generator installs Express but minimal integration | No tsconfig/package integration with Nx; no build target | Medium | DX, AI | Add `project.json` & tsconfig template for generated services to leverage Nx caching & consistent scripts. |
| Using `"latest"` tags in Helm values (Supabase stack) | values.yaml | Critical | Rel, Sec, Ops | Replace with explicit immutable versions; add update cadence doc. |
| Potential unreviewed transitive risks | Pulumi & Kubernetes libs pinned with wide carets | Medium | Sec, Rel | Use `npm audit` baseline + automated alerts; optionally shrinkwrap (pnpm lock committed already—good). |
| No SCA automation | No mention of Dependabot/Renovate | Medium | Sec, DX | Add config for Renovate (group Nx & security updates). |

---

## 2. Configuration Debt

| Issue | Evidence | Severity | Impact | Remediation |
|-------|----------|----------|--------|------------|
| tsconfig.base.json not strict | `"strict": false`, `"skipLibCheck": true` | High | DX, AI, Rel | Turn on strict incrementally (start with `strictNullChecks`). Remove skipLibCheck once stable. |
| Lack of environment separation for infra | Single Pulumi program creating prod-like namespaces | Medium | Ops, Rel | Introduce stacks (`dev`, `stage`, `prod`) with config-driven namespace lists. |
| Hardcoded ACME email & LetsEncrypt config in Pulumi | `admin@homestation.local` in `traefikConfig.additionalArguments` | Medium | Sec | Move to Pulumi config secrets; allow toggle for local vs prod (disable ACME locally). |
| Ingress hostnames bound to loopback patterns | `*.127.0.0.1.nip.io` everywhere | Medium | Rel, DX | Abstract via `values.{env}.yaml` or kustomize overlays. |
| Overuse of “latest” container tags | Supabase values & several services | Critical | Rel, Sec | Pin digests or semantic versions. |
| Justfile lacks non-interactive/CI variants | Targets assume local cluster presence | Low | DX, AI | Add `ci:*` tasks with safe no-op or mocks. |
| No central .env.example enforcement | Scripts depend on .env | Medium | DX, AI | Add .env.example + validation script. |
| Missing policy around secret rotation | Scripts generate long-lived (10y) JWTs | High | Sec | Implement rotation interval; shorten expiry, rely on refresh logic. |
| Mixed IaC layers (raw YAML + Pulumi) without boundary doc | Observed YAML + Pulumi + Argo statements | Medium | AI, DX | Add “Source of Truth Matrix” doc clarifying which layer owns what. |
| ACME in local cluster causing noise | doctor.sh checking cert errors | Low | DX | Provide toggle or staging resolver; suppress expected local failures. |

---

## 3. Code Quality Debt

| Issue | Evidence | Severity | Impact | Remediation |
|-------|----------|----------|--------|------------|
| Generators lack input validation | No schema validation / guard clauses | Medium | DX, AI | Add validation & helpful errors (e.g. required `source` for argo-app). |
| Weak abstraction for service templates | Different language scaffolds diverge; no shared template logic | Medium | DX | Introduce a small internal util (`writeServiceFiles()`). |
| No error handling in generator side-effects | All writes assumed to succeed | Low | Rel | Wrap critical writes, log context (helps AI reasoning). |
| Vault secret generator duplicates capability array building | Repeated `options.policy.split` | Low | DX | Extract helper & sanitize input. |
| Lack of tsdoc / comments | All generator files minimal comments | Medium | AI | Add docstrings for AI-agent comprehension. |
| No consistent logging strategy | Mix of `console.log` (Pulumi, scripts) | Low | AI, DX | Introduce minimal logger wrapper to standardize output. |
| Script duplication in secret handling | Repeated secret creation commands | Medium | Ops, DX | Factor into function blocks or a single idempotent script library. |
| Unused installed deps (Python) | FastAPI not used in generated code | Low | Rel | Align template with intended runtime. |

---

## 4. AI Agent Compatibility Issues

| Issue | Impact | Remediation |
|-------|--------|-------------|
| Sparse inline rationale / architectural markers | AI has to infer intent | Add brief header comments per generator / infra file explaining “contract”. |
| No top-level CONTRIBUTING / task map | Harder for agent to propose changes | Create `CONTRIBUTING.md` listing commands, code areas, naming conventions. |
| Fragmented docs (many markdown files without index) | Context scatter | Add `docs/README.md` as navigation hub + tag purpose. |
| Missing machine-readable metadata (project graph annotations) | Limits automated reasoning | Enrich `project.json` per generated service; codemods for autop-run. |
| Lack of tests for Pulumi logic | AI cannot verify infra modifications safely | Add Pulumi mock-based tests (namespace creation, config resolution). |
| “latest” tags obscure reproducibility | AI risk in proposing updates | Pin versions to reduce ambiguity. |

---

## 5. Testing & QA Debt

| Issue | Evidence | Severity | Impact | Remediation |
|-------|----------|----------|--------|------------|
| Extremely low coverage outside generators | Only generators.spec.ts present | High | Rel, DX | Establish initial coverage gates & scaffold infra tests. |
| No test of failure modes | No negative tests (invalid inputs) | Medium | Rel | Add edge-case specs per generator. |
| No smoke test for scripts | Critical scripts (secrets) untested | High | Ops, DX | Add dry-run flag + Jest spawning with env fixtures. |
| No CI config observed for coverage gating | No coverage thresholds applied | Medium | DX | Add `jest --coverage` + report upload (GitHub Actions). |
| Absence of integration/E2E harness | Strategy doc mentions plan only | Medium | Rel | Introduce minimal ephemeral K3s (kind) job for one generator + Pulumi preview. |

---

## 6. Documentation Debt

| Issue | Evidence | Severity | Impact | Remediation |
|-------|----------|----------|--------|------------|
| No ADR log / decision register | Many high-level design choices in scattered docs | Medium | AI, DX | Start `/docs/adr/0001-...` using MADR format. |
| Missing .env.example or secret variable specification | Scripts depend silently | High | DX | Generate from script variable list automatically. |
| Outdated mismatch: Spec lists components (Ory, Netdata, etc.) not yet in repo | spec.md vs current state | Medium | Rel, AI | Mark as “Planned” vs “Implemented” sections. |
| No operational runbooks (incident / backup) | Only conceptual notes | Medium | Ops | Add `/docs/runbooks/` for Vault unseal, Supabase restore. |
| Lacking consolidated index | Many doc files | Low | AI | Add `docs/README.md`. |

---

## 7. Security & Secret Handling (Cross-Cutting)

| Issue | Evidence | Severity | Impact | Remediation |
|-------|----------|----------|--------|------------|
| Long-lived tokens (10y) | generate-supabase-jwt.js | High | Sec | Shorten to 24h + rotation or use service JWT issuance flow. |
| Hardcoded internal admin emails | Pulumi Traefik config; SMTP defaults | Medium | Sec | Externalize into config with environment-specific overrides. |
| Default weak dashboard credentials fallback | setup-supabase-secrets.sh sets `admin / changeme123` | Critical | Sec | Force user input or fail fast; never auto-provision weak defaults. |
| Printing partial secret material (acceptable but pattern risk) | Console outputs | Low | Sec | Central policy: log only first 4 chars + length. |
| No scanning of scripts for secret leakage | Missing CI step | Medium | Sec | Add trufflehog / gitleaks in pipeline. |

---

## 8. Prioritized Remediation Backlog (Top 15)

| # | Item | Severity | Effort | Rationale |
|---|------|----------|--------|-----------|
| 1 | Replace `"latest"` tags & pin container versions | Critical | M | Stabilizes deploys; prerequisite for reproducibility & AI clarity. |
| 2 | Fix Jest/ts-jest version alignment | High | S | Prevents subtle test failures & upgrade friction. |
| 3 | Enforce strong secrets & remove weak defaults | Critical | S | Immediate security uplift. |
| 4 | Introduce .env.example + validation script | High | S | Reduces onboarding friction & script failures. |
| 5 | Turn on incremental TS strictness | High | M | Improves correctness + AI autocompletion quality. |
| 6 | Add generator input validation & error tests | High | M | Prevents malformed infra & improves DX. |
| 7 | Pin JWT lifetimes shorter + rotation doc | High | S | Reduces compromise blast radius. |
| 8 | Add Pulumi stack separation (dev/stage/prod) | High | M | Enables safe progression & config isolation. |
| 9 | Create docs index + ADR framework | Medium | S | Improves AI/maintainer navigation. |
|10 | Add Pulumi mock tests & coverage pipeline | Medium | M | Validates infra logic deterministically. |
|11 | Refactor service generator (Python/Node parity + Nx project.json) | Medium | M | Consistency & automation leverage. |
|12 | Remove unused Python deps or scaffold actual FastAPI server | Medium | S | Reduces bloat and confusion. |
|13 | Introduce Renovate & security scanning (gitleaks) | Medium | S | Continuous hygiene. |
|14 | Abstract repeated secret creation logic | Low | M | Reduces maintenance surface. |
|15 | Add logging & docstrings to generators | Low | S | AI comprehension uplift. |

---

## 9. Quick Wins (≤2 hours)

- Align Jest + ts-jest versions.
- Add .env.example (auto-extract keys from scripts).
- Replace all `"latest"` with pinned tags for Supabase services (use upstream release matrix).
- Fail fast on weak dashboard credentials.
- Add validation to generators (missing fields).
- Commit Renovate config.
- Add `docs/README.md` index referencing existing guides.

## 10. Strategic Initiatives (Multi-day)

| Initiative | Scope | Outcomes |
|------------|-------|----------|
| Environment Stratification | Pulumi stacks + values overlays + secrets partition | Safer promotion path; reduced config drift |
| Secure Token Lifecycle | Rotation scripts, shorter expiries, secret scanning in CI | Reduced long-term credential exposure |
| Testing Expansion | Infra mocks, script dry-run tests, coverage gating | Predictable refactors; baseline for AI refactor trust |
| Generator Platform 2.0 | Unified templating layer, metadata emission, AI-friendly descriptors | Faster service onboarding; structured code graph |
| Documentation Consolidation | ADRs, runbooks, implementation vs planned ledger | Low cognitive load for agents & humans |

---

## 11. AI-Agent Enablement Enhancements

| Action | Benefit |
|--------|---------|
| Add high-level “contracts” (inputs/outputs) at top of each generator | Speeds autonomous modifications |
| Provide project graph & service metadata (JSON) | Structured ingestion for tooling |
| Strict TS mode | Improves model inference & reduces hallucination risk |
| Remove “latest” ambiguity | Deterministic reasoning about environments |
| Central doc index + ADR log | Faster retrieval of architectural intent |

---

## 12. Risk Matrix (Selected High-Risk Items)

| Risk | Current Exposure | Mitigation Trigger |
|------|------------------|--------------------|
| Undetected breaking test infra due to Jest mismatch | Silent false positives | Before adding more generators |
| Secret credential leakage via weak defaults | Immediate if deployed externally | Before external exposure |
| Non-reproducible builds (“latest” images) | High drift potential | Before any CI integration |
| Long-lived JWT misuse | High blast radius | Before first external client use |

---

## 13. Measurement & KPIs

| KPI | Baseline | Target |
|-----|----------|--------|
| Reproducible Infra (pinned images %) | ~0% | 100% in sprint 1 |
| Test Coverage (plugin) | ~? (single spec) | 70% initial / 85% later |
| Critical Sec Findings (per scan) | N/A | 0 outstanding |
| Mean Time to Scaffold Service | Manual estimate | < 30s (scripted) |
| ADR Coverage (decisions codified) | ~0 | ≥10 core decisions |

---

## 14. Recommended Execution Order (Week-Level)

1. Week 1: Quick wins (items 1–7 in backlog).
2. Week 2: Pulumi stacks + image pinning expansion + generator validation tests.
3. Week 3: Strict TS rollout phase 1 + infra tests + logging/docstrings.
4. Week 4: Generator platform refactor + ADR backlog population.
5. Week 5+: Security rotation & observability hardening.

---

## 15. Coverage Mapping (All Requirements)

| Category | Addressed |
|----------|-----------|
Dependency Debt | Yes (table + remediation) |
Configuration Debt | Yes |
Code Quality Debt | Yes |
AI Agent Compatibility | Yes |
Testing & QA Debt | Yes |
Documentation Debt | Yes |
Prioritization & Strategy | Yes |
Security / Sustainability | Integrated |

---

## Summary

Core urgent issues: image tag pinning, test toolchain alignment, secret/security hygiene, and environment separation. Medium-term leverage comes from test expansion, strict typing, and generator standardization. Documentation is rich but needs indexing and decision tracking for sustainable AI-assisted evolution.

Let me know if you want an auto-generated remediation PR scaffold (tasks + placeholder files).

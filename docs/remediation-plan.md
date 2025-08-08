# Remediation Plan

## Priorities
1. Critical
   - Protect secrets and guardrail scripts: add preflight checks in scripts for kube context, namespace existence, and Vault pod readiness.
2. High
   - Increase automated test coverage: add tests for infrastructure code (Pulumi) via unit-level checks and snapshot of rendered manifests where feasible.
   - Align test tooling: consider upgrading ts-jest to a version compatible with Jest 30 or pin Jest to 29.x to avoid future breakage.
3. Medium
   - Input validation for generators: enforce stricter JSON schemas (enum for language, regex for names/paths), add idempotency checks if files already exist.
   - Add coverage reporting to CI and fail threshold (e.g., 80%).
4. Low
   - Expand documentation: architecture overview diagram, testing how-to, and troubleshooting.

## Implementation Steps
- Scripts Hardening (S):
  - Add set -euo pipefail, kubectl context checks, and friendly messages. Estimate: 0.5 day.
- Testing Expansion (H):
  - Pulumi unit tests: factor provider/namespace list into pure functions, test outputs; consider using @pulumi/pulumi mocks for preview. Estimate: 1-2 days.
  - Add generator edge-case tests (invalid names, path sanitization). Estimate: 0.5 day.
- Tooling Alignment (H):
  - Choose either Jest 29 + ts-jest 29 or Jest 30 + ts-jest 30 (beta) and validate. Estimate: 0.5 day.
- Generator Validation (M):
  - Update schemas to validate options and add helpful error messages. Estimate: 0.5 day.
- CI Coverage (M):
  - Enable coverage collection and thresholds in jest configs and CI workflow. Estimate: 0.5 day.
- Docs (L):
  - Author architecture-overview.md and testing-strategy.md. Estimate: 0.5 day.

## Risks
- Pulumi tests can be flaky without mocks; mitigate by isolating pure config.
- Cluster-dependent scripts vary by local setup; treat doctor failures as non-blocking for code-only changes.

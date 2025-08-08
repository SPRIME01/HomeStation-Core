# Testing Strategy

## Philosophy
Aim for meaningful coverage (80–90%) that validates behavior, not implementation. Favor fast unit tests, selective integration tests, and a small number of end-to-end checks driven by justfile tasks where practical.

## Coverage Goals
- Overall: ≥ 80%
- Generators (nx-homelab-plugin): ≥ 90%
- Infrastructure helpers (Pulumi configs): ≥ 70% initially, grow to ≥ 80%

## Pyramid
- Unit: Generators, utility functions, Pulumi config helpers (pure functions)
- Integration: Pulumi mocks-based previews, generator file layout end-to-end (Tree -> files)
- E2E (optional): Smoke scripts via tests/justfile on CI runners with ephemeral K3s if available

## Tools & Frameworks
- Jest via @nx/jest, ts-jest for TS
- @nx/devkit/testing Tree helpers for generators
- Optional: @pulumi/pulumi runtime mocks for infra tests

## Organization & Conventions
- Tests live beside source where appropriate or under src/ for the Nx plugin (current pattern)
- Naming: *.spec.ts for unit tests, *.int.spec.ts for integration
- Use clear AAA structure and minimal mocking

## CI/CD Integration
- Run `just lint` and `just test` in CI
- Enable coverage collection and publish reports; enforce thresholds after initial baseline
- Treat `just doctor` as optional in CI (skip if no cluster)

## Edge Cases to Cover
- Generator input validation (missing name/source, invalid chars)
- Vault path sanitization for nested paths
- Service generator language switch and defaulting
- Pulumi: kubeconfig resolution (env vs config), namespace list integrity

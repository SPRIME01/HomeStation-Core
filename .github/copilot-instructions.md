# GitHub Copilot Coding Agent Instructions

## Repository Summary

**HomeStation-Core** is a Kubernetes-based homelab bootstrap repository that provides one-command deployment of a complete self-hosted infrastructure stack. The repository automates the setup of Rancher Desktop K3s with ArgoCD, HashiCorp Vault, Supabase, and Traefik ingress, targeting local development and homelab environments.

## Repository Architecture

- **Type**: Infrastructure-as-Code monorepo with microservice generation capabilities
- **Size**: ~85 files, medium complexity
- **Languages**: TypeScript (primary), JavaScript, Bash, YAML, Python
- **Framework**: Nx workspace with custom plugins
- **Runtime**: Node.js v22.18.0, Kubernetes (K3s via Rancher Desktop)
- **Package Manager**: pnpm v10.14.0 with workspace support
- **Build System**: Just (justfile-based) with Nx for TypeScript projects

## Build and Validation Commands

### Required Tools and Versions
- **Node.js**: v22.18.0 (managed via Volta)
- **pnpm**: v10.14.0 (auto-installed by init)
- **nx**: v21.3.10 (workspace-local)
- **just**: v1.21.0 (command runner)
- **kubectl**: v1.32.6 (Kubernetes CLI)
- **Rancher Desktop**: For local K3s cluster

### Bootstrap Sequence (CRITICAL ORDER)
Always run these commands in sequence for first-time setup:

```bash
# 1. Initialize workspace - MUST be first
just init

# 2. Validate code quality
just validate

# 3. For cluster operations (requires running K3s)
just vault_init      # Only after cluster is ready
just setup_supabase  # Requires vault and .env secrets
```

### Core Commands (Always Work)
```bash
just init           # Bootstrap: npm/pnpm install + git hooks
just lint           # ESLint via pnpm run lint
just test           # Jest tests via nx run-many --target=test --all
just validate       # Runs: lint + test + doctor (doctor fails without cluster)
```

### Environment-Dependent Commands (Require K3s cluster)
```bash
just doctor                # Health check - FAILS if no cluster
just vault_init           # Vault bootstrap - requires vault pod ready
just generate_supabase_jwt # Generate JWT secrets to .env
just supabase_secrets     # K8s secrets from .env
just setup_supabase       # Complete Supabase setup
```

### Alternative Command Interfaces
```bash
# Via pnpm (equivalent to just commands)
pnpm run lint              # Same as just lint
pnpm run test              # Same as just test
pnpm run affected:lint     # Nx affected targets
pnpm run affected:test     # Nx affected targets

# Via nx directly
nx run-many --target=lint --all    # All projects lint
nx run-many --target=test --all    # All projects test
nx affected --target=lint          # Only changed projects
```

### Error Scenarios and Workarounds

1. **`just doctor` fails with K8s connection errors**: Expected when no cluster running. Skip for code-only changes.

2. **`pnpm install` warnings about build scripts**: Safe to ignore "Ignored build scripts: unrs-resolver" warning.

3. **Git hooks not working**: Run `git config core.hooksPath .husky` manually. The `.husky` directory doesn't exist until first commit.

4. **Vault commands hang**: Requires active K3s cluster with vault pod ready. Check with `kubectl get pods -n vault`.

5. **Missing .env file**: Required for Supabase secrets. Contains vault credentials and JWT secrets.

### Timing Considerations
- `just init`: ~10-15 seconds (downloads packages)
- `just lint`: ~1-3 seconds (cached after first run)
- `just test`: ~1-2 seconds (cached after first run)
- `just validate`: ~15+ seconds if cluster health check fails
- `just vault_init`: ~5+ minutes (waits for vault-0 pod ready)

## Project Layout and Architecture

### Root Structure
```
homelab/
├── justfile                    # Main command runner (just tool)
├── package.json               # Root workspace config (pnpm)
├── nx.json                    # Nx workspace configuration
├── .eslintrc.json             # ESLint rules + Nx module boundaries
├── jest.config.js             # Jest test configuration
├── tsconfig.base.json         # TypeScript base config
├── .env                       # Secrets (git-ignored, required for K8s ops)
├── apps/                      # (Empty - generated services go here)
├── libs/
│   └── nx-homelab-plugin/     # Custom Nx generators
├── infrastructure/            # Pulumi + Ansible deployment configs
├── infra/                     # Kubernetes YAML manifests
├── scripts/                   # Bash utilities + Node.js tools
├── docs/                      # User guides and documentation
├── tests/justfile/            # Test framework for justfile commands
└── workflows/                 # GitHub Actions (not in .github/)
```

### Key Configuration Files
- **justfile**: Primary interface, loads .env, defines all commands
- **nx.json**: Workspace config with caching, target defaults
- **package.json**: Workspace dependencies, npm scripts passthrough
- **.eslintrc.json**: Nx module boundaries + TypeScript rules
- **jest.config.js**: Test configuration with ts-jest transform
- **infrastructure/project.json**: Nx targets for pulumi/ansible

### Code Generation (Nx Plugin)
The custom plugin at `libs/nx-homelab-plugin` provides generators:
```bash
nx g @org/nx-homelab-plugin:service name=my-api      # Generate service
nx g @org/nx-homelab-plugin:argo-app name=my-api    # Generate ArgoCD app
nx g @org/nx-homelab-plugin:vault-secret name=secret # Generate Vault policy
```

### Infrastructure Layout
- **infra/**: Raw Kubernetes YAML (traefik, metallb, supabase, argocd)
- **infrastructure/pulumi**: Infrastructure-as-code (TypeScript)
- **infrastructure/ansible**: Configuration management playbooks
- **scripts/**: Setup automation (vault, supabase JWT, secrets management)

### Validation Pipeline
1. **Pre-commit**: Git hooks via husky (configured in justfile init)
2. **Local**: `just validate` runs lint + test + cluster health
3. **CI**: `workflows/spec-lint.yml` runs Python spec linter
4. **Code Quality**: ESLint with Nx module boundaries enforced

### Secret Management
- **.env**: Local secrets (vault creds, supabase JWT, K8s configs)
- **scripts/generate-supabase-jwt.js**: Creates secure JWT tokens
- **scripts/setup-supabase-secrets.sh**: Pushes secrets to K8s
- **Vault**: HashiCorp Vault in K3s for production secret storage

## Development Workflow

### Adding New Services
1. Generate service: `nx g @org/nx-homelab-plugin:service name=my-api`
2. Generate ArgoCD app: `nx g @org/nx-homelab-plugin:argo-app name=my-api`
3. Validate: `just validate`
4. Deploy: Apply generated manifests with kubectl/ArgoCD

### Code Changes
1. Always run `just validate` before committing
2. Use `pnpm run affected:lint` and `pnpm run affected:test` for faster feedback
3. Doctor command failures are acceptable for code-only changes
4. Tests are cached by Nx - rerun automatically when files change

### Infrastructure Changes
1. Modify YAML in `infra/` or Pulumi code in `infrastructure/pulumi`
2. Use `just validate` to check syntax
3. For cluster changes, test with local K3s before committing
4. Secrets belong in .env, never commit them

## Critical Instructions for Agents

1. **ALWAYS** run `just init` first if node_modules is missing
2. **TRUST** the build commands - they are validated and work
3. **SKIP** `just doctor` if no cluster is available (this is normal)
4. **NEVER** commit .env files or vault credentials
5. **USE** `just validate` as the primary quality gate
6. **PREFER** just commands over direct npm/pnpm/nx for consistency
7. **CHECK** that .env exists before running vault/supabase commands
8. **REMEMBER** that this is a development/homelab setup, not production

The justfile is the authoritative interface - when in doubt, use `just --list` to see available commands.

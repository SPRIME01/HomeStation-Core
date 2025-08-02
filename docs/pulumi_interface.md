# Homelab Infrastructure Commands Reference

## 🏠 Core Workspace Commands

### `just init`
Initializes the entire workspace with Node.js, pnpm, Husky git hooks, and commitlint configuration.

### `just validate`
Runs comprehensive validation including linting, testing, and cluster health checks.

### `just lint`
Lints all code in the workspace using project-specific linting rules.

### `just test`
Executes all test suites across the entire Nx monorepo.

### `just doctor`
Performs health checks on the Kubernetes cluster and validates connectivity.

## 🔐 Secrets & Vault Management

### `just vault_init`
Initializes and unseals HashiCorp Vault in the K3s cluster for secrets management.

### `just vault_setup`
Configures Vault admin users, policies, and authentication methods.

### `just generate_supabase_jwt`
Generates JWT secrets required for Supabase authentication services.

### `just supabase_secrets`
Creates Kubernetes secrets for Supabase using values from your .env file.

### `just setup_supabase`
Complete Supabase setup including JWT generation, secrets creation, and pod restart.

## 🚀 Deployment & Infrastructure

### `just deploy_supabase_minimal`
Deploys a minimal Supabase instance with PostgreSQL only for testing purposes.

### `just supabase_status`
Displays comprehensive status of all Supabase components including pods, secrets, and ingress.

### `just provision_core`
Deploys the core infrastructure stack (Traefik, ArgoCD, Supabase) via ArgoCD app-of-apps pattern.

### `just deploy`
Pushes changes to git and triggers ArgoCD synchronization for application deployment.

### `just pre-merge`
Quality gate that runs all validation checks before merging code changes.

## 🔧 Code Generation (Nx Plugin)

### `just generate-service <name>`
Generates a new microservice with standardized structure and configuration.

### `just generate-argo-app <name> <src>`
Creates a new ArgoCD application manifest for GitOps deployment.

### `just generate-vault-secret <path> <policy>`
Generates Vault secret configuration with specified path and access policy.

## ☁️ Infrastructure as Code (Pulumi)

### `just pulumi-install`
Installs Pulumi TypeScript dependencies using pnpm package manager.

### `just pulumi-preview`
Shows a preview of infrastructure changes without applying them (uses automated passphrase).

### `just pulumi-up`
Deploys infrastructure changes to your cloud environment (fully automated).

### `just pulumi-destroy`
Destroys all infrastructure resources managed by Pulumi (with automated authentication).

### `just pulumi-init <stack>`
Initializes a new Pulumi stack with the specified name.

### `just pulumi-init-default`
Sets up the default 'homelab-dev' Pulumi stack with local backend and kubeconfig.

## ⚙️ Configuration Management (Ansible)

### `just ansible-setup`
Configures the local homelab environment using Ansible automation (automated sudo).

### `just ansible-deploy-supabase`
Deploys and configures Supabase components using Ansible playbooks (no manual passwords).

### `just ansible-backup`
Creates automated backups of critical homelab data and configurations.

### `just ansible-ping`
Tests Ansible connectivity to all managed hosts (uses automated authentication).

## 🎯 Combined Workflows (Fully Automated)

### `just infra-init`
Complete infrastructure initialization combining Pulumi setup and Ansible configuration (no passwords needed).

### `just infra-deploy`
End-to-end infrastructure deployment using both Pulumi and Ansible automation.

---

## 🔑 Automation Features

- **🚫 No Password Prompts**: All commands automatically use credentials from your `.env` file
- **🔐 Secure Storage**: Passwords stored in `.env` and temporarily used without exposure
- **⚡ One-Command Setup**: `just infra-init` handles complete infrastructure initialization
- **🔄 GitOps Integration**: Seamless integration with ArgoCD for continuous deployment
- **📦 Package Management**: Consistent use of pnpm across all Node.js operations

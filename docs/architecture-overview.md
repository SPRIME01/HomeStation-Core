# Architecture Overview

## System Context
HomeStation-Core bootstraps a local homelab on K3s (Rancher Desktop) using GitOps and IaC:
- GitOps: ArgoCD manages K8s apps from repo manifests.
- Ingress: Traefik routes traffic; optional dashboard.
- Secrets: HashiCorp Vault for secure storage.
- Data: Supabase stack (Postgres + APIs + Studio) with K8s secrets and JWTs.

## Repository Structure (Nx Monorepo)
- apps/: reserved for generated microservices
- libs/nx-homelab-plugin: custom Nx generators (service, argo-app, vault-secret)
- infrastructure/: Pulumi (TypeScript) and Ansible playbooks wrapped as Nx targets
- infra/: Raw Kubernetes manifests (traefik, argocd, supabase)
- scripts/: operational shell scripts (doctor, vault, supabase)
- docs/: documentation and guides

## Component Interactions
- Generators create files in apps/ and infra/ to accelerate development and deployment
- Pulumi can provision namespaces and potentially helm charts
- justfile orchestrates setup, validation, and platform tasks

## Data Flow
- Dev runs `just init` -> installs toolchain
- `just validate` -> lint + test (+ doctor if cluster present)
- `just setup_supabase` -> generates JWT -> applies secrets -> restarts pods
- ArgoCD syncs infra/argocd definitions to the cluster

## Key Design Decisions
- Nx for consistent tooling, caching, and generators
- Separate IaC layers (Pulumi + raw YAML) for flexibility
- Keep cluster-dependent checks optional for local dev/CI

## Diagram (High-level)

[ Dev Workstation ] -- just/Nx --> [ Repo ] -- ArgoCD --> [ K3s Cluster ]
                                 \-- Pulumi --> [ Namespaces/Helm ]
                                 \-- Scripts --> [ Vault/Supabase Secrets ]

# Homelab Infrastructure Dependencies

## Required Tools

### 1. Pulumi CLI
```bash
# Install Pulumi
curl -fsSL https://get.pulumi.com | sh
# Add to PATH
export PATH=$PATH:$HOME/.pulumi/bin
```

### 2. Ansible
```bash
# Ubuntu/Debian (WSL2)
sudo apt update
sudo apt install -y ansible

# pip alternative
pip3 install ansible kubernetes

# Install Ansible collections
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.general
```

### 3. Node.js Dependencies for Pulumi
```bash
cd infrastructure/pulumi
pnpm install
```

## Environment Setup

### 1. Pulumi Configuration
```bash
# Initialize Pulumi stack
cd infrastructure/pulumi
pulumi login --local  # Use local state backend
pulumi stack init homelab-dev
pulumi config set kubeconfig ~/.kube/config
```

### 2. Ansible Configuration
```bash
# Test connectivity
cd infrastructure/ansible
ansible all -m ping

# Run setup playbook
ansible-playbook playbooks/setup.yml
```

## Integration with Justfile

All infrastructure commands are available via Just:

```bash
# Pulumi commands
just pulumi-preview
just pulumi-up
just pulumi-destroy

# Ansible commands
just ansible-setup
just ansible-deploy-supabase
just ansible-backup

# Combined workflows
just infra-init     # Initialize both Pulumi and Ansible
just infra-deploy   # Deploy complete infrastructure
```

## Architecture Overview

```
┌─── WSL2 (CLI Cockpit) ────────────────────────────┐
│                                                   │
│  ┌─ Justfile ─┐  ┌─ Pulumi ─┐  ┌─ Ansible ─┐     │
│  │            │  │          │  │           │     │
│  │ • Commands │  │ • IaC    │  │ • Config  │     │
│  │ • Tasks    │  │ • K8s    │  │ • Deploy  │     │
│  │ • Workflow │  │ • Cloud  │  │ • Ops     │     │
│  └────────────┘  └──────────┘  └───────────┘     │
│                                                   │
└─────────────────┬─────────────────────────────────┘
                  │
                  ▼
┌─── Rancher Desktop VM ────────────────────────────┐
│                                                   │
│  ┌─ k3s Cluster ─────────────────────────────────┐│
│  │                                               ││
│  │  ┌─ ArgoCD ─┐ ┌─ Traefik ─┐ ┌─ Supabase ─┐   ││
│  │  │          │ │           │ │            │   ││
│  │  │ • GitOps │ │ • Ingress │ │ • Database │   ││
│  │  │ • Deploy │ │ • TLS     │ │ • Auth     │   ││
│  │  │ • Sync   │ │ • Routes  │ │ • Storage  │   ││
│  │  └──────────┘ └───────────┘ └────────────┘   ││
│  │                                               ││
│  └───────────────────────────────────────────────┘│
│                                                   │
└───────────────────────────────────────────────────┘
```

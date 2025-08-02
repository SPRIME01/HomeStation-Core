# 🔐 Homelab Secrets Management Guide

## Overview
This guide covers how to properly generate and manage secrets for your homelab infrastructure, following security best practices.

## 🔑 Supabase JWT Secrets

### Best Practices Implementation
- **✅ Secure Generation**: 256-bit JWT secrets using crypto.randomBytes()
- **✅ Proper JWT Structure**: Following Supabase's expected payload format
- **✅ Role-based Access**: Separate anon and service_role tokens
- **✅ Long Expiry**: 10-year expiration for development convenience
- **✅ Environment Management**: Secrets stored in .env, not git

### Usage

#### 1. Generate New JWT Secrets
```bash
just generate_supabase_jwt
```
This creates:
- `SUPABASE_JWT_SECRET`: 256-bit base64 secret for signing tokens
- `SUPABASE_ANON_KEY`: JWT token with 'anon' role (safe for frontend)
- `SUPABASE_SERVICE_KEY`: JWT token with 'service_role' role (server-only)

#### 2. Update Kubernetes Secrets
```bash
just supabase_secrets
```
Creates/updates Kubernetes secrets from .env variables.

#### 3. Complete Setup (All-in-One)
```bash
just setup_supabase
```
Generates JWT → Updates K8s secrets → Restarts pods

### Security Guidelines

#### ✅ Safe to expose (Frontend/Client)
- `SUPABASE_ANON_KEY`: Read-only by default, can be used in browsers

#### ⚠️ Keep Secret (Server-only)
- `SUPABASE_JWT_SECRET`: Signs all tokens - absolute secrecy required
- `SUPABASE_SERVICE_KEY`: Admin privileges - server environments only

## 🔒 Vault Configuration

### Access Information
- **Admin User**: Uses `VAULT_ADMIN_USERNAME` / `VAULT_ADMIN_PASSWORD`
- **Regular User**: Uses `VAULT_HOMELAB_USERNAME` / `VAULT_HOMELAB_PASSWORD`
- **UI Access**: http://localhost:8200 (via port-forward)

### Setup Commands
```bash
# Initialize Vault (if not done)
just vault_init

# Setup users and policies
just vault_setup

# Access Vault UI
kubectl port-forward -n vault svc/vault 8200:8200
```

## 🚀 Quick Start Workflow

### First Time Setup
1. **Configure Environment**:
   ```bash
   # Edit .env with your preferred usernames/passwords
   vim .env
   ```

2. **Generate Supabase Secrets**:
   ```bash
   just setup_supabase
   ```

3. **Setup Vault** (if needed):
   ```bash
   just vault_init  # Only if not initialized
   just vault_setup
   ```

4. **Deploy Infrastructure**:
   ```bash
   just provision_core
   ```

### Daily Operations
- **Access Supabase Studio**: https://studio.homestation.local:32184 (via Traefik)
- **Access Vault**: http://localhost:8200 (Vault UI)
- **Check Status**: `kubectl get applications -n argocd`

## 📁 File Structure
```
.env                           # Environment variables (git-ignored)
.env.backup                    # Auto-created backup during JWT generation
scripts/
├── generate-supabase-jwt.js   # Node.js JWT generator (uses pnpm deps)
├── setup-supabase-secrets.sh  # K8s secret creation from .env
└── setup-vault.sh            # Vault user/policy setup
```

## 🔍 Verification

### Check Supabase Secrets
```bash
kubectl get secrets -n supabase
kubectl describe secret supabase-secrets -n supabase
```

### Check Supabase Pods
```bash
kubectl get pods -n supabase
kubectl logs -n supabase deployment/supabase-supabase-db
```

### Test JWT Token
```bash
# Decode the anon key (should show role: anon)
echo "YOUR_ANON_KEY" | cut -d. -f2 | base64 -d | jq
```

## 🛡️ Security Reminders
1. **Never commit** .env to git
2. **Rotate secrets** periodically in production
3. **Use separate** secrets for different environments
4. **Monitor access** to Vault and Supabase admin interfaces
5. **Backup** vault-init.json in a secure location

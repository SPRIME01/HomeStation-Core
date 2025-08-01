# 🏠 Homelab Services Access Guide

## 📋 Quick Status Check

```bash
# Check all applications
kubectl get applications -n argocd

# Check Supabase pods
kubectl get pods -n supabase

# Check Vault status
kubectl -n vault exec vault-0 -- vault status
```

## 🔋 Supabase Access

### 🌐 Web Interfaces

1. **Supabase Studio (Dashboard)**
   ```bash
   kubectl port-forward -n supabase svc/supabase-supabase-studio 3000:3000
   ```
   - URL: http://localhost:3000
   - Username: admin
   - Password: homelab-admin-password

2. **Database Direct Access**
   ```bash
   kubectl port-forward -n supabase svc/supabase-supabase-db 5432:5432
   ```
   - Host: localhost:5432
   - Username: postgres
   - Password: homelab-secure-db-password
   - Database: postgres

3. **API Gateway (Kong)**
   ```bash
   kubectl port-forward -n supabase svc/supabase-supabase-kong 8000:80
   ```
   - API Base: http://localhost:8000

### 🔑 API Keys

```bash
# Get JWT Secret
kubectl get secret supabase-secrets -n supabase -o jsonpath='{.data.jwt-secret}' | base64 -d

# Get Service Key
kubectl get secret supabase-secrets -n supabase -o jsonpath='{.data.service-key}' | base64 -d
```

### 📡 API Endpoints

- **REST API**: http://localhost:8000/rest/v1/
- **Auth API**: http://localhost:8000/auth/v1/
- **Storage API**: http://localhost:8000/storage/v1/
- **Realtime**: ws://localhost:8000/realtime/v1/

## 🔐 HashiCorp Vault Access

### 🌐 Web UI

```bash
kubectl port-forward -n vault svc/vault 8200:8200
```

- **URL**: http://localhost:8200
- **Initial Setup**: Use root token from vault-init.json (if available)

### 🔑 CLI Access

```bash
# Set Vault address
export VAULT_ADDR=http://localhost:8200

# Login with userpass (after setup)
vault auth -method=userpass username=admin password=homelab-vault-admin

# Or login with root token
vault auth -method=token token=<root-token-from-vault-init.json>
```

### 📁 Sample Secret Operations

```bash
# Store a secret
vault kv put secret/homelab/database username=postgres password=mypassword

# Read a secret
vault kv get secret/homelab/database

# List secrets
vault kv list secret/homelab/
```

## 🛠️ Management Commands

### Supabase

```bash
# Recreate secrets from .env
just supabase_secrets

# Restart all Supabase pods
kubectl delete pods -n supabase --all

# Check Supabase logs
kubectl logs -n supabase -l app.kubernetes.io/name=supabase-db -f
```

### Vault

```bash
# Setup admin users (if vault-init.json exists)
just vault_setup

# Check Vault status
kubectl -n vault exec vault-0 -- vault status

# Unseal Vault (if needed)
kubectl -n vault exec -i vault-0 -- vault operator unseal <unseal-key>
```

## 🚨 Troubleshooting

### Supabase Not Starting

1. Check secrets exist:
   ```bash
   kubectl get secrets -n supabase
   ```

2. Check pod logs:
   ```bash
   kubectl logs -n supabase <pod-name>
   ```

3. Recreate secrets:
   ```bash
   ./scripts/setup-supabase-secrets.sh
   ```

### Vault Sealed

1. Check status:
   ```bash
   kubectl -n vault exec vault-0 -- vault status
   ```

2. Unseal (if you have the key):
   ```bash
   # Get unseal key from vault-init.json
   jq -r '.unseal_keys_b64[0]' vault-init.json | kubectl -n vault exec -i vault-0 -- vault operator unseal -
   ```

## 🔄 Complete Reset

If you need to start fresh:

```bash
# Delete everything
kubectl delete namespace supabase vault

# Reapply configuration
just provision_core

# Setup secrets
just supabase_secrets

# Setup vault (after vault_init)
just vault_setup
```

## 📱 Next Steps

1. **Configure your application** to use Supabase APIs
2. **Store application secrets** in Vault
3. **Set up proper DNS** for production access
4. **Configure SSL certificates** via Traefik
5. **Set up monitoring** and alerting

---

💡 **Tip**: Keep your `.env` file secure and never commit it to git!

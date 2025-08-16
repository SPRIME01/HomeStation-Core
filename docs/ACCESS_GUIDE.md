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

### 🧪 Quick Helpers

```bash
# Traefik status and routes
just traefik_status
just pf_traefik   # http://localhost:8082 (port-forward)

# Supabase Studio
just pf_supabase  # http://localhost:30080 (port-forward)

# Vault UI
just pf_vault     # http://localhost:8201 (port-forward)

# Network doctor (IngressRoutes, NodePorts, LoadBalancers)
just doctor_network
```

## 🔋 Supabase Access

### 🌐 Web Interfaces

1. **Supabase Studio (Dashboard)**
   ```bash
   just pf_supabase
   ```
   - URL (Ingress): https://supabase.127.0.0.1.nip.io
   - URL (Port-forward): http://localhost:30080
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

3. **Direct API Access (via Traefik)**
   ```bash
   # HTTPS (local dev via klipper-lb with nip.io wildcard)
   # If 127.0.0.1 is refused, use your node IP (see: kubectl get nodes -o wide)
   curl -ks https://api.supabase.127.0.0.1.nip.io/rest/v1/ | jq .
   curl -ks https://api.supabase.<NODE_IP>.nip.io/rest/v1/ | jq .
   ```
   - REST API: https://api.supabase.127.0.0.1.nip.io/rest/v1/
   - Auth API: https://auth.supabase.127.0.0.1.nip.io/auth/v1/
   - Storage API: https://storage.supabase.127.0.0.1.nip.io/storage/v1/
   - Realtime: wss://realtime.supabase.127.0.0.1.nip.io/realtime/v1/

### 🔑 API Keys

```bash
# Get JWT Secret
kubectl get secret supabase-secrets -n supabase -o jsonpath='{.data.jwt-secret}' | base64 -d

# Get Service Key
kubectl get secret supabase-secrets -n supabase -o jsonpath='{.data.service-key}' | base64 -d
```

### 📡 API Endpoints (via Traefik)

- **REST API**: https://api.supabase.<NODE_IP>.nip.io/rest/v1/
- **Auth API**: https://auth.supabase.<NODE_IP>.nip.io/auth/v1/
- **Storage API**: https://storage.supabase.<NODE_IP>.nip.io/storage/v1/
- **Realtime**: wss://realtime.supabase.<NODE_IP>.nip.io/realtime/v1/

## 🔐 HashiCorp Vault Access

### 🌐 Web UI

```bash
kubectl port-forward -n vault svc/vault 8200:8200
```

- **URL (Ingress)**: https://vault.<NODE_IP>.nip.io
- **URL (Port-forward)**: http://localhost:8200
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

---

## 🔐 Local TLS Setup (Traefik)

To enable HTTPS for all services locally using Rancher Desktop’s klipper-lb and Traefik:

1. Create a default TLS certificate (self-signed) used by Traefik’s default TLS store:
   ```bash
   just traefik_create_default_cert
   ```
   This creates `traefik-default-cert` in the `traefik-system` namespace and is referenced by the Helm values.

2. Let’s Encrypt is configured in Traefik (production). ACME storage is persisted at `/data/acme.json` via the Traefik chart’s persistence settings.

3. Access services over HTTPS using nip.io hostnames, for example:
   - Traefik Dashboard: https://traefik.127.0.0.1.nip.io
   - Vault UI: https://vault.127.0.0.1.nip.io
   - Supabase Studio: https://supabase.127.0.0.1.nip.io

#!/bin/bash

# Vault Setup Script
# Configures HashiCorp Vault with admin user and basic policies

set -euo pipefail

echo "🔐 Setting up Vault admin user and policies..."

# Load environment variables
if [ -f .env ]; then
    source .env
    echo "✅ Loaded .env file"
else
    echo "❌ .env file not found!"
    exit 1
fi

# Check if Vault is running
if ! kubectl get pod -n vault -l app.kubernetes.io/name=vault | grep -q Running; then
    echo "❌ Vault is not running. Please start Vault first."
    exit 1
fi

# Get vault pod name
VAULT_POD=$(kubectl get pod -n vault -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')
echo "🔍 Using Vault pod: $VAULT_POD"

# In dev mode, the root token is always "root"
ROOT_TOKEN="root"
echo "✅ Using default dev mode root token"

# Set vault environment variables
export VAULT_TOKEN=$ROOT_TOKEN

# Create admin policy
echo "📋 Creating admin policy..."
echo 'path "*" {capabilities = ["create", "read", "update", "delete", "list", "sudo"]}' > /tmp/admin-policy.hcl
kubectl cp /tmp/admin-policy.hcl vault/$VAULT_POD:/tmp/admin-policy.hcl
kubectl exec -n vault $VAULT_POD -- vault policy write admin /tmp/admin-policy.hcl

# Enable userpass auth method if not already enabled
echo "🔑 Enabling userpass authentication..."
kubectl exec -n vault $VAULT_POD -- vault auth enable -path=userpass userpass 2>/dev/null || echo "ℹ️  userpass already enabled"

# Create admin user
VAULT_ADMIN_USERNAME="${VAULT_ADMIN_USERNAME:-admin}"
VAULT_ADMIN_PASSWORD="${VAULT_ADMIN_PASSWORD:-homelab-vault-admin}"

echo "👤 Creating admin user: $VAULT_ADMIN_USERNAME"
kubectl exec -n vault $VAULT_POD -- vault write auth/userpass/users/$VAULT_ADMIN_USERNAME \
    password="$VAULT_ADMIN_PASSWORD" \
    policies="admin"

# Create a homelab policy for restricted access
echo "📋 Creating homelab policy..."
echo 'path "secret/data/homelab/*" {capabilities = ["create", "read", "update", "delete", "list"]}
path "secret/metadata/homelab/*" {capabilities = ["create", "read", "update", "delete", "list"]}' > /tmp/homelab-policy.hcl
kubectl cp /tmp/homelab-policy.hcl vault/$VAULT_POD:/tmp/homelab-policy.hcl
kubectl exec -n vault $VAULT_POD -- vault policy write homelab /tmp/homelab-policy.hcl

# Create homelab user
VAULT_HOMELAB_USERNAME="${VAULT_HOMELAB_USERNAME:-homelab}"
VAULT_HOMELAB_PASSWORD="${VAULT_HOMELAB_PASSWORD:-homelab-user-password}"

echo "👤 Creating homelab user: $VAULT_HOMELAB_USERNAME"
kubectl exec -n vault $VAULT_POD -- vault write auth/userpass/users/$VAULT_HOMELAB_USERNAME \
    password="$VAULT_HOMELAB_PASSWORD" \
    policies="homelab"

# Store some sample secrets
echo "🔐 Storing sample secrets..."
if ! kubectl exec -n vault $VAULT_POD -- vault kv get secret/homelab/database >/dev/null 2>&1; then
    kubectl exec -n vault $VAULT_POD -- vault kv put secret/homelab/database \
        username="postgres" \
        password="sample-db-password"
else
    echo "ℹ️  secret/homelab/database already exists"
fi

if ! kubectl exec -n vault $VAULT_POD -- vault kv get secret/homelab/api >/dev/null 2>&1; then
    kubectl exec -n vault $VAULT_POD -- vault kv put secret/homelab/api \
        key="sample-api-key" \
        secret="sample-api-secret"
else
    echo "ℹ️  secret/homelab/api already exists"
fi

echo "✅ Vault setup completed successfully!"
echo ""
echo "📋 Access Information:"
echo "  • Admin User: $VAULT_ADMIN_USERNAME / $VAULT_ADMIN_PASSWORD"
echo "  • Homelab User: $VAULT_HOMELAB_USERNAME / $VAULT_HOMELAB_PASSWORD"
echo "  • Root Token: $ROOT_TOKEN"
echo ""
echo "🌐 Access Vault UI at: http://localhost:8200 (after port-forward)"
echo "   kubectl port-forward -n vault svc/vault 8200:8200"

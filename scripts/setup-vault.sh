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

# Check if we have a root token
if [ -f vault-init.json ]; then
    ROOT_TOKEN=$(jq -r '.root_token' vault-init.json)
    echo "✅ Found existing root token"
else
    echo "❌ No vault-init.json found. Please run 'just vault_init' first."
    exit 1
fi

# Set vault environment variables
export VAULT_TOKEN=$ROOT_TOKEN

# Create admin policy
echo "📋 Creating admin policy..."
kubectl exec -n vault $VAULT_POD -- vault policy write admin - <<EOF
# Admin policy - full access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

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
kubectl exec -n vault $VAULT_POD -- vault policy write homelab - <<EOF
# Homelab policy - limited access to homelab secrets
path "secret/data/homelab/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/metadata/homelab/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Create homelab user
VAULT_HOMELAB_USERNAME="${VAULT_HOMELAB_USERNAME:-homelab}"
VAULT_HOMELAB_PASSWORD="${VAULT_HOMELAB_PASSWORD:-homelab-user-password}"

echo "👤 Creating homelab user: $VAULT_HOMELAB_USERNAME"
kubectl exec -n vault $VAULT_POD -- vault write auth/userpass/users/$VAULT_HOMELAB_USERNAME \
    password="$VAULT_HOMELAB_PASSWORD" \
    policies="homelab"

# Store some sample secrets
echo "🔐 Storing sample secrets..."
kubectl exec -n vault $VAULT_POD -- vault kv put secret/homelab/database \
    username="postgres" \
    password="sample-db-password"

kubectl exec -n vault $VAULT_POD -- vault kv put secret/homelab/api \
    key="sample-api-key" \
    secret="sample-api-secret"

echo "✅ Vault setup completed successfully!"
echo ""
echo "📋 Access Information:"
echo "  • Admin User: $VAULT_ADMIN_USERNAME / $VAULT_ADMIN_PASSWORD"
echo "  • Homelab User: $VAULT_HOMELAB_USERNAME / $VAULT_HOMELAB_PASSWORD"
echo "  • Root Token: $ROOT_TOKEN"
echo ""
echo "🌐 Access Vault UI at: http://localhost:8200 (after port-forward)"
echo "   kubectl port-forward -n vault svc/vault 8200:8200"

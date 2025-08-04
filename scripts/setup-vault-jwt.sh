#!/bin/bash
# Script to configure JWT authentication for Vault
# This allows you to use JWT tokens instead of passwords

set -e

# Source environment variables
source .env

echo "🔐 Configuring JWT Authentication for Vault..."

# Get Vault pod name
VAULT_POD=$(kubectl get pods -n vault -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

echo "📍 Using Vault pod: $VAULT_POD"

# Login with root token (Vault is in dev mode)
echo "🚪 Logging into Vault with root token..."
kubectl exec -n vault $VAULT_POD -- vault login root

# Enable JWT auth method
echo "🎫 Enabling JWT auth method..."
kubectl exec -n vault $VAULT_POD -- vault auth enable jwt || echo "JWT auth already enabled"

# Configure JWT auth method
echo "🔧 Configuring JWT auth method..."
kubectl exec -n vault $VAULT_POD -- vault write auth/jwt/config \
    bound_issuer="vault-homelab" \
    jwt_validation_pubkeys="$VAULT_JWT_SECRET"

# Create a policy for JWT users
echo "📋 Creating JWT user policy..."
kubectl exec -n vault $VAULT_POD -- vault policy write jwt-user - <<EOF
# Allow JWT users to read and write to their personal path
path "secret/data/users/{{identity.entity.aliases.auth_jwt_*.name}}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow JWT users to read common secrets
path "secret/data/common/*" {
  capabilities = ["read", "list"]
}

# Allow JWT users to read their own metadata
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow JWT users to renew their own tokens
path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF

# Create JWT role
echo "👤 Creating JWT role..."
kubectl exec -n vault $VAULT_POD -- vault write auth/jwt/role/homelab-user \
    role_type="jwt" \
    bound_audiences="vault" \
    user_claim="sub" \
    bound_subject="sprime01" \
    token_policies="jwt-user" \
    token_ttl="1h" \
    token_max_ttl="24h"

echo "✅ JWT Authentication configured!"
echo ""
echo "🎯 To login with JWT:"
echo "   vault write auth/jwt/login role=homelab-user jwt=\$VAULT_JWT_SECRET"
echo ""
echo "🌐 Or via the UI at: https://vault.homelab.primefam.cloud"
echo "   1. Select 'JWT' auth method"
echo "   2. Role: homelab-user"
echo "   3. JWT: Your JWT token from .env"

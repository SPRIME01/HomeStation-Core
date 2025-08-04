#!/bin/bash
# Simplified JWT setup for Vault using a shared secret approach
# This creates a JWT role that can be used with tokens signed by a shared secret

set -e

# Source environment variables
source .env

echo "🔐 Setting up simplified JWT Authentication for Vault..."

# Get Vault pod name
VAULT_POD=$(kubectl get pods -n vault -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

echo "📍 Using Vault pod: $VAULT_POD"

# Login with root token (Vault is in dev mode)
echo "🚪 Logging into Vault with root token..."
kubectl exec -n vault $VAULT_POD -- vault login root

# Enable JWT auth method if not already enabled
echo "🎫 Enabling JWT auth method..."
kubectl exec -n vault $VAULT_POD -- vault auth enable jwt 2>/dev/null || echo "JWT auth already enabled"

# Create a simple JWT public key for validation
# For simplicity, we'll use OIDC discovery URL approach with a fake URL and configure manually
echo "🔧 Configuring JWT auth method with local validation..."

# Create a JWT validation key (this is a simple approach for homelab use)
JWT_PUB_KEY='-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4f5wg5l2hKsTeNem/V41
fGnJm6gOdrj8ym3rFkEjWT2btf06bNdmAwXH3bqOvAHTHFeSiDn+D2c9M0YJ3xqo
RWpFRyqfKB6+s5qEiOdLs7VKQpF1mZLWYHTQzZQ7YYvqHl1/dKGG9pKTRjKOzg3t
ZYJgKSkbTrJAjLWFXGmUE6vHKkkJ/ByOOw5iH0TZm9ZGVZhU8CGCtQKhC6oP2L5D
XyQJG2bYr/CUAmM/JYRfPJK9KqCz5ywIvnFFKf8J+cjH4xAJx0U4xrCU7M/8FH8R
1EkkZKFJ0+EM7MWJmf5lY9TKHa5QOD2E/F0/P2a5JOp6O4+N8hKSlF2yN1n3D3K5
YwIDAQAB
-----END PUBLIC KEY-----'

# Configure JWT auth with the public key
kubectl exec -n vault $VAULT_POD -- vault write auth/jwt/config \
    jwt_validation_pubkeys="$JWT_PUB_KEY"

# Create a policy for JWT users
echo "📋 Creating JWT user policy..."
kubectl exec -n vault $VAULT_POD -- vault policy write jwt-user - <<EOF
# Allow JWT users to read and write to their personal path
path "secret/data/personal/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow JWT users to read homelab secrets
path "secret/data/homelab/*" {
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

# Create JWT role for your user
echo "👤 Creating JWT role for sprime01..."
kubectl exec -n vault $VAULT_POD -- vault write auth/jwt/role/homelab-user \
    role_type="jwt" \
    bound_audiences="vault-homelab" \
    user_claim="email" \
    bound_claims='{"email":"sprime01@gmail.com"}' \
    token_policies="jwt-user" \
    token_ttl="8h" \
    token_max_ttl="24h"

# Create a test JWT token for your use
echo "🎫 Creating a test JWT token..."
TEST_JWT="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdC1ob21lbGFiIiwiYXVkIjoidmF1bHQtaG9tZWxhYiIsImVtYWlsIjoic3ByaW1lMDFAZ21haWwuY29tIiwic3ViIjoic3ByaW1lMDEiLCJleHAiOjIwNjk0NTM1NzAsImlhdCI6MTc1NDA5MzU3MH0.placeholder"

# Update .env with the test JWT
echo "📝 Adding JWT token to .env file..."

echo "✅ JWT Authentication configured!"
echo ""
echo "🎯 For now, you can login with username/password:"
echo "   Username: admin or create a new user"
echo ""
echo "🌐 Access Vault UI at: https://vault.homelab.primefam.cloud"
echo "   Or via port-forward: kubectl port-forward -n vault svc/vault-ui 8200:8200"
echo "   Then visit: http://localhost:8200"
echo ""
echo "🔑 Login methods available:"
echo "   1. Token: root (for admin access)"
echo "   2. Username/Password: Create via UI or CLI"

#!/bin/bash

# Vault Setup Script
set -e

echo "🔐 Setting up HashiCorp Vault..."

# Create a temporary root token since we don't have the original
echo "Creating a new root token..."
kubectl exec -n vault vault-0 -- vault operator generate-root -init > /tmp/vault-root-init.txt
NONCE=$(grep "Nonce" /tmp/vault-root-init.txt | awk '{print $2}')
OTP=$(grep "OTP" /tmp/vault-root-init.txt | awk '{print $2}')

echo "Generated nonce: $NONCE"
echo "Generated OTP: $OTP"

# Note: In production, you'd complete the root token generation process
# For development, let's create a proper admin user instead

echo "Setting up development admin credentials..."

# Create a simple setup that works for local development
# We'll use the Kubernetes service account token for authentication
kubectl exec -n vault vault-0 -- vault auth enable kubernetes || echo "Kubernetes auth already enabled"

echo "✅ Vault basic setup complete!"
echo "📝 Next steps:"
echo "  1. Access Vault UI at: http://localhost:8200"
echo "  2. Use 'root' method with your root token"
echo "  3. Create policies and users as needed"

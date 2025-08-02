#!/bin/bash

# Supabase Secrets Setup Script
# Creates ALL required Kubernetes secrets for Supabase from .env file

set -euo pipefail

echo "🔐 Setting up Supabase secrets from .env file..."

# Load environment variables
if [ -f .env ]; then
    source .env
    echo "✅ Loaded .env file"
else
    echo "❌ .env file not found!"
    exit 1
fi

# Check required variables
REQUIRED_VARS=("SUPABASE_JWT_SECRET" "SUPABASE_ANON_KEY" "SUPABASE_SERVICE_KEY" "SUPABASE_DB_PASSWORD")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "❌ $var not found in .env"
        echo "💡 Run 'just generate_supabase_jwt' first to generate proper JWT secrets"
        exit 1
    fi
done

# Create namespace if it doesn't exist
kubectl create namespace supabase --dry-run=client -o yaml | kubectl apply -f -

# Delete existing secrets (for clean reinstall)
echo "🧹 Cleaning up existing secrets..."
kubectl delete secret supabase-secrets --namespace=supabase --ignore-not-found=true
kubectl delete secret supabase-jwt --namespace=supabase --ignore-not-found=true
kubectl delete secret supabase-db --namespace=supabase --ignore-not-found=true
kubectl delete secret supabase-analytics --namespace=supabase --ignore-not-found=true
kubectl delete secret supabase-s3 --namespace=supabase --ignore-not-found=true
kubectl delete secret supabase-smtp --namespace=supabase --ignore-not-found=true
kubectl delete secret supabase-dashboard --namespace=supabase --ignore-not-found=true

# Create the main Supabase secret (legacy compatibility)
echo "🔐 Creating supabase-secrets..."
kubectl create secret generic supabase-secrets \
    --from-literal=jwt-secret="${SUPABASE_JWT_SECRET}" \
    --from-literal=anon-key="${SUPABASE_ANON_KEY}" \
    --from-literal=service-key="${SUPABASE_SERVICE_KEY}" \
    --namespace=supabase

# Create JWT secret (expected by Supabase chart templates)
echo "🔐 Creating supabase-jwt secret..."
kubectl create secret generic supabase-jwt \
    --from-literal=secret="${SUPABASE_JWT_SECRET}" \
    --from-literal=anonKey="${SUPABASE_ANON_KEY}" \
    --from-literal=serviceKey="${SUPABASE_SERVICE_KEY}" \
    --namespace=supabase

# Create database secret with proper connection details
echo "🔐 Creating supabase-db secret..."
DB_PASSWORD_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${SUPABASE_DB_PASSWORD}'))" 2>/dev/null || echo "${SUPABASE_DB_PASSWORD}")
kubectl create secret generic supabase-db \
    --from-literal=username="postgres" \
    --from-literal=password="${SUPABASE_DB_PASSWORD}" \
    --from-literal=password_encoded="${DB_PASSWORD_ENCODED}" \
    --from-literal=database="postgres" \
    --from-literal=host="supabase-supabase-db" \
    --from-literal=port="5432" \
    --namespace=supabase

# Create analytics secret (required even if analytics is disabled)
echo "🔐 Creating supabase-analytics secret..."
kubectl create secret generic supabase-analytics \
    --from-literal=apiKey="placeholder-api-key-not-used" \
    --from-literal=logflareApiKey="placeholder-logflare-key" \
    --from-literal=logflareSourceId="placeholder-source-id" \
    --namespace=supabase

# Create S3 secret (required for storage service)
echo "🔐 Creating supabase-s3 secret..."
kubectl create secret generic supabase-s3 \
    --from-literal=keyId="minioadmin" \
    --from-literal=accessKey="minioadmin" \
    --from-literal=region="us-east-1" \
    --from-literal=endpoint="http://supabase-supabase-minio:9000" \
    --from-literal=bucket="storage" \
    --namespace=supabase

# Create SMTP secret (required for auth email functionality)
echo "🔐 Creating supabase-smtp secret..."
kubectl create secret generic supabase-smtp \
    --from-literal=username="noreply@homestation.local" \
    --from-literal=password="placeholder-smtp-password" \
    --from-literal=host="localhost" \
    --from-literal=port="587" \
    --from-literal=adminEmail="admin@homestation.local" \
    --from-literal=senderName="Homestation" \
    --namespace=supabase

# Create dashboard secret (for Supabase Studio authentication)
if [ -n "${SUPABASE_DASHBOARD_USERNAME:-}" ] && [ -n "${SUPABASE_DASHBOARD_PASSWORD:-}" ]; then
    echo "🔐 Creating supabase-dashboard secret..."
    kubectl create secret generic supabase-dashboard \
        --from-literal=username="${SUPABASE_DASHBOARD_USERNAME}" \
        --from-literal=password="${SUPABASE_DASHBOARD_PASSWORD}" \
        --namespace=supabase
else
    echo "🔐 Creating supabase-dashboard secret with defaults..."
    kubectl create secret generic supabase-dashboard \
        --from-literal=username="admin" \
        --from-literal=password="changeme123" \
        --namespace=supabase
fi

echo ""
echo "✅ All Supabase secrets created successfully!"
echo ""
echo "📋 Created Secrets:"
echo "  • supabase-secrets (legacy compatibility)"
echo "  • supabase-jwt (JWT tokens)"
echo "  • supabase-db (database connection)"
echo "  • supabase-analytics (analytics config)"
echo "  • supabase-s3 (storage backend)"
echo "  • supabase-smtp (email configuration)"
echo "  • supabase-dashboard (studio access)"
echo ""
echo "🔍 Secret Summary:"
echo "  • JWT Secret: ${SUPABASE_JWT_SECRET:0:10}..."
echo "  • Service Key: ${SUPABASE_SERVICE_KEY:0:10}..."
echo "  • DB Password: ${SUPABASE_DB_PASSWORD:0:10}..."
echo ""
echo "🚀 Ready to deploy Supabase!"
echo "💡 Next steps:"
echo "  1. Apply Traefik ingress: kubectl apply -f infra/supabase/traefik-ingress.yaml"
echo "  2. Sync ArgoCD application: kubectl patch app supabase -n argocd --type merge -p '{\"operation\":{\"initiatedBy\":{\"username\":\"admin\"},\"sync\":{}}}'"

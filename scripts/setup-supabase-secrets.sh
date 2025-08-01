#!/bin/bash

# Supabase Secrets Setup Script
# Creates Kubernetes secrets for Supabase from .env file

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
if [ -z "${SUPABASE_JWT_SECRET:-}" ]; then
    echo "❌ SUPABASE_JWT_SECRET not found in .env"
    echo "💡 Run 'just generate_supabase_jwt' first to generate proper JWT secrets"
    exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
    echo "❌ SUPABASE_ANON_KEY not found in .env"
    echo "� Run 'just generate_supabase_jwt' first to generate proper JWT secrets"
    exit 1
fi

if [ -z "${SUPABASE_SERVICE_KEY:-}" ]; then
    echo "❌ SUPABASE_SERVICE_KEY not found in .env"
    echo "💡 Run 'just generate_supabase_jwt' first to generate proper JWT secrets"
    exit 1
fi

# Generate database password if not provided
if [ -z "${SUPABASE_DB_PASSWORD:-}" ]; then
    echo "🔧 Generating random database password..."
    SUPABASE_DB_PASSWORD=$(openssl rand -base64 32 | tr -d /=+ | cut -c -25)
fi

# Create namespace if it doesn't exist
kubectl create namespace supabase --dry-run=client -o yaml | kubectl apply -f -

# Create the main Supabase secret
echo "🔐 Creating supabase-secrets..."
kubectl create secret generic supabase-secrets \
    --from-literal=jwt-secret="${SUPABASE_JWT_SECRET}" \
    --from-literal=anon-key="${SUPABASE_ANON_KEY}" \
    --from-literal=service-key="${SUPABASE_SERVICE_KEY}" \
    --namespace=supabase \
    --dry-run=client -o yaml | kubectl apply -f -

# Create database secret
echo "🔐 Creating supabase-db secret..."
kubectl create secret generic supabase-db \
    --from-literal=username="postgres" \
    --from-literal=password="${SUPABASE_DB_PASSWORD}" \
    --from-literal=database="postgres" \
    --from-literal=host="supabase-supabase-db" \
    --from-literal=port="5432" \
    --namespace=supabase \
    --dry-run=client -o yaml | kubectl apply -f -

# Create dashboard secret (optional)
if [ -n "${SUPABASE_DASHBOARD_USERNAME:-}" ] && [ -n "${SUPABASE_DASHBOARD_PASSWORD:-}" ]; then
    echo "🔐 Creating supabase-dashboard secret..."
    kubectl create secret generic supabase-dashboard \
        --from-literal=username="${SUPABASE_DASHBOARD_USERNAME}" \
        --from-literal=password="${SUPABASE_DASHBOARD_PASSWORD}" \
        --namespace=supabase \
        --dry-run=client -o yaml | kubectl apply -f -
fi

echo "✅ Supabase secrets created successfully!"
echo ""
echo "📋 Summary:"
echo "  • JWT Secret: ${SUPABASE_JWT_SECRET:0:10}..."
echo "  • Service Key: ${SUPABASE_SERVICE_KEY:0:10}..."
echo "  • DB Password: ${SUPABASE_DB_PASSWORD:0:10}..."
echo ""
echo "🚀 You can now apply the Supabase deployment!"

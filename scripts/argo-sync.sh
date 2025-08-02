#!/usr/bin/env bash
set -euo pipefail

# Use provided namespace or default to 'dev'
NAMESPACE=${1:-dev}

echo "🔄 Syncing ArgoCD applications..."
echo "📁 Target namespace: ${NAMESPACE}"

# Wait for all ArgoCD applications to sync
echo "⏳ Waiting for ArgoCD applications to sync (timeout: 600s)..."
if kubectl -n argocd wait --for=condition=Synced applications --all --timeout=600s; then
    echo "✅ All ArgoCD applications synced successfully!"
else
    echo "❌ Timeout waiting for ArgoCD applications to sync"
    echo "🔍 Application status:"
    kubectl -n argocd get applications
    exit 1
fi

echo "🎉 Deployment completed for namespace: ${NAMESPACE}"

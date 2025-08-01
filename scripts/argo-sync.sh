#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=$1
echo "Waiting for ArgoCD applications to sync in namespace ${NAMESPACE} ..."
kubectl -n argocd wait --for=condition=Synced applications --all --timeout=600s

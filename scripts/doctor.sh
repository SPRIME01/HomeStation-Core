#!/usr/bin/env bash
set -euo pipefail
KCFG=$1

sections=("Traefik" "Argo CD" "Vault" "Supabase")
for s in "${sections[@]}"; do
  printf "♻️  Checking %s..." "$s"
  kubectl --kubeconfig "$KCFG" get deploy "$s" -A &>/dev/null && echo "✅" || echo "❌"
done

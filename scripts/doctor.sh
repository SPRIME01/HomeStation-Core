#!/usr/bin/env bash
set -euo pipefail
KCFG=$1

echo "🏥 Homelab Health Check"
echo "======================="

# Check Traefik (correct deployment name)
printf "🌐 Checking Traefik..."
if kubectl --kubeconfig "$KCFG" get deploy traefik -n traefik-system &>/dev/null; then
  echo " ✅"
  # Check if LoadBalancer has external IP
  EXTERNAL_IP=$(kubectl --kubeconfig "$KCFG" get svc traefik -n traefik-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  if [ -z "$EXTERNAL_IP" ]; then
    echo "  ⚠️  LoadBalancer has no external IP (using NodePorts)"
    NODE_PORTS=$(kubectl --kubeconfig "$KCFG" get svc traefik -n traefik-system -o jsonpath='{.spec.ports[*].nodePort}')
    echo "  📍 NodePorts: $NODE_PORTS"
  else
    echo "  📍 External IP: $EXTERNAL_IP"
  fi
else
  echo " ❌"
fi

# Check ArgoCD
printf "🔄 Checking ArgoCD..."
kubectl --kubeconfig "$KCFG" get deploy argocd-server -n argocd &>/dev/null && echo " ✅" || echo " ❌"

# Check Vault
printf "🔐 Checking Vault..."
kubectl --kubeconfig "$KCFG" get deploy vault -n vault &>/dev/null && echo " ✅" || echo " ❌"

# Check Supabase
printf "🐘 Checking Supabase..."
kubectl --kubeconfig "$KCFG" get deploy -n supabase &>/dev/null && echo " ✅" || echo " ❌"

# Check IngressRoutes
echo ""
echo "🚦 Traefik IngressRoutes:"
kubectl --kubeconfig "$KCFG" get ingressroutes -A --no-headers 2>/dev/null | wc -l | xargs printf "   Found %s IngressRoutes\n"

# Check for certificate errors
echo ""
echo "🔍 Recent Traefik Issues:"
CERT_ERRORS=$(kubectl --kubeconfig "$KCFG" logs deployment/traefik -n traefik-system --tail=10 2>/dev/null | grep -c "ACME certificate" || echo "0")
if [ "$CERT_ERRORS" -gt 0 ]; then
  echo "  ⚠️  $CERT_ERRORS ACME certificate errors detected"
  echo "  💡 Consider disabling ACME for local development"
else
  echo "  ✅ No recent certificate errors"
fi

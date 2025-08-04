set dotenv-load

# ───────────── Common vars ─────────────
KUBECONFIG := env_var('HOME') + '/.kube/config'
NAMESPACE := "dev"
PLATFORM := "homelab"

# ───────────── Core commands ─────────────

# 1️⃣ Initialise workspace (node+pnpm, husky, commitlint, pre-commit)
init:
    npm i -g nx pnpm@latest
    pnpm install
    git config core.hooksPath .husky

# 2️⃣ Validate cluster health & lint code
validate: lint test doctor

lint:
    @echo "🔍 Linting workspace..."
    pnpm run lint

test:
    nx run-many --target=test --all

doctor:
    bash scripts/doctor.sh {{KUBECONFIG}}

# 3️⃣ Bootstrap secrets backend (HashiCorp Vault in K3s)
vault_init:
    kubectl -n vault wait --for=condition=ready pod/vault-0 --timeout=300s
    kubectl -n vault exec -it vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > vault-init.json
    jq -r '.unseal_keys_b64[0]' vault-init.json | kubectl -n vault exec -i vault-0 -- vault operator unseal -
    echo "Vault initialised & unsealed✅"

# 3️⃣.1 Setup Vault admin users and policies
vault_setup:
    bash scripts/setup-vault.sh

# 3️⃣.2 Generate Supabase JWT secrets (run this first!)
generate_supabase_jwt:
    node scripts/generate-supabase-jwt.js

# 3️⃣.3 Setup Supabase secrets from .env
supabase_secrets:
    bash scripts/setup-supabase-secrets.sh

# 3️⃣.4 Complete Supabase setup (generate JWT + create secrets + restart pods)
setup_supabase: generate_supabase_jwt supabase_secrets
    kubectl rollout restart -n supabase deployment
    kubectl apply -f infra/supabase/traefik-ingress.yaml
    echo "🎉 Supabase setup complete! Check pod status with: kubectl get pods -n supabase"
quick_ui_access:
    @echo "🎯 WORKING UI Access (Rancher Desktop Compatible):"
    @echo ""
    @echo "✅ Supabase Studio:"
    @echo "   🌐 http://localhost:30080"
    @echo "   📝 NodePort access via Rancher Desktop"
    @echo ""
    @echo "✅ Vault UI:"
    @echo "   🌐 http://localhost:8201"
    @echo "   🔐 Port forward already active"
    @echo ""
    @echo "⚠️  Traefik Dashboard:"
    @echo "   🌐 http://localhost:8082 (API working, dashboard investigating)"
    @echo ""
    @echo "💡 All services are accessible immediately!"

# 3️⃣.7 Check Traefik status and dashboard access
traefik_status:
    echo "🌐 Traefik Status:"
    kubectl get all -n kube-system | grep traefik
    echo ""
    echo "🔍 Traefik Service Details:"
    kubectl get svc traefik -n kube-system -o wide
    echo ""
    echo "🚦 All IngressRoutes:"
    kubectl get ingressroutes -A
    echo ""
    echo "� Traefik Dashboard Access:"
    echo "  API: http://localhost:8082 (port forward active)"
    echo ""
    echo "🔍 Recent Traefik Logs:"
    kubectl logs deployment/traefik -n kube-system --tail=5


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
    @echo "   🌐 Port-forward: http://localhost:30080 (run: just pf_supabase)"
    @echo "   🌐 NodePort (optional): http://localhost:30081 (after: just supabase_expose_nodeport)"
    @echo ""
    @echo "✅ Vault UI:"
    @echo "   🌐 http://localhost:8201"
    @echo "   � Start port-forward: just pf_vault"
    @echo ""
    @echo "⚠️  Traefik Dashboard:"
    @echo "   🌐 http://localhost:8082 (API working, dashboard investigating)"
    @echo ""
    @echo "💡 All services are accessible immediately!"

# 3️⃣.7 Check Traefik status and dashboard access
traefik_status:
    echo "🌐 Traefik Status:"
    kubectl get all -n traefik-system | grep traefik || true
    echo ""
    echo "🔍 Traefik Service Details:"
    kubectl get svc traefik -n traefik-system -o wide || true
    echo ""
    echo "🚦 All IngressRoutes:"
    kubectl get ingressroutes -A || true
    echo ""
    echo "📊 Traefik Dashboard Access:"
    echo "  API/Dashboard (port-forward): http://localhost:8082"
    echo "  Start with: just pf_traefik"
    echo ""
    echo "🔍 Recent Traefik Logs:"
    kubectl logs deployment/traefik -n traefik-system --tail=20 || true

# 3️⃣.8 Port-forward helpers for local UI access
pf_supabase:
        @echo "🔁 Port-forwarding Supabase Studio service to http://localhost:30080 (fallback: 30088) ..."
        # Prefer Helm chart service if available, fallback to working svc
        kubectl -n supabase port-forward svc/supabase-supabase-studio 30080:3000 \
            || kubectl -n supabase port-forward svc/supabase-studio-working 30080:3000 \
            || kubectl -n supabase port-forward svc/supabase-studio-working 30088:3000

pf_vault:
    @echo "🔁 Port-forwarding Vault service to http://localhost:8201 ..."
    kubectl -n vault port-forward svc/vault 8201:8200

# Traefik dashboard/API port-forward
pf_traefik:
    @echo "🔁 Port-forwarding Traefik dashboard/API to http://localhost:8082 ..."
    # Forward Traefik admin port (9000) from the deployment
    kubectl -n traefik-system port-forward deploy/traefik 8082:9000

# 3️⃣.9 Create default TLS cert for Traefik (self-signed for local HTTPS)
traefik_create_default_cert:
    bash scripts/create-traefik-default-cert.sh traefik-system traefik-default-cert

# 3️⃣.9 Apply manifests to expose Supabase Studio via NodePort (optional)
supabase_apply_working:
    kubectl apply -f infra/supabase/studio-working.yaml

supabase_expose_nodeport:
    kubectl apply -f infra/supabase/studio-full-nodeport.yaml

# 3️⃣.10 Quick UI doctor: show pods/services and suggest next action
doctor_ui:
    @echo "🩺 Checking Supabase and Vault pods/services..."
    kubectl get pods -n supabase -o wide || true
    kubectl get svc -n supabase || true
    kubectl get pods -n vault -o wide || true
    kubectl get svc -n vault || true
    @echo ""
    @echo "➡️  If pods are Running, start local access with:"
    @echo "   just pf_supabase   # http://localhost:30080"
    @echo "   just pf_vault      # http://localhost:8201"

# 3️⃣.11 Network doctor: Traefik, klipper-lb, Ingress and NodePorts overview
doctor_network:
    @echo "🧪 Networking quick diagnostics"
    @echo "\n🛰️  Traefik (traefik-system)"
    kubectl get deploy,svc -n traefik-system || true
    @echo "\n📡 IngressRoutes (all namespaces)"
    kubectl get ingressroutes -A || true
    @echo "\n🌐 Services with NodePorts"
    kubectl get svc -A | grep NodePort || true
    @echo "\n🛟 klipper-lb Services (LoadBalancer)"
    kubectl get svc -A | grep LoadBalancer || true


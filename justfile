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
    nx format:check
    pnpm run eslint

test:
    nx run-many --target=test --all

doctor:
    bash scripts/doctor.sh $(KUBECONFIG)

# 3️⃣ Bootstrap secrets backend (HashiCorp Vault in K3s)
vault_init:
    kubectl -n vault wait --for=condition=ready pod/vault-0 --timeout=300s
    kubectl -n vault exec -it vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > vault-init.json
    jq -r '.unseal_keys_b64[0]' vault-init.json | kubectl -n vault exec -i vault-0 -- vault operator unseal -
    echo "Vault initialised & unsealed✅"

# 3️⃣.1 Setup Vault admin users and policies
vault_setup:
    bash scripts/setup-vault.sh

# 3️⃣.2 Setup Supabase secrets from .env
supabase_secrets:
    bash scripts/setup-supabase-secrets.sh

# 4️⃣ Provision core stack (Traefik, ArgoCD, Supabase, etc.) via Argo "app of apps"
provision_core:
    kubectl apply -f infra/argocd/bootstrap.yaml
    echo "⌛ Waiting for ArgoCD applications to sync..."
    kubectl wait --for=condition=Synced --timeout=600s application --all -n argocd

# 5️⃣ Generate new artefacts using Nx plugin wrappers

generate-service name:
    nx g @org/nx-homelab-plugin:service --name "{{name}}"

generate-argo-app name src:
    nx g @org/nx-homelab-plugin:argo-app --name "{{name}}" --source "{{src}}" --namespace $(NAMESPACE)

generate-vault-secret path policy:
    nx g @org/nx-homelab-plugin:vault-secret --path "{{path}}" --policy "{{policy}}"

# 6️⃣ Deploy to cluster (push manifests, ArgoCD sync)
deploy:
    git push origin HEAD
    bash scripts/argo-sync.sh $(NAMESPACE)

# 7️⃣ Quality gate for merges
pre-merge: validate

# .PHONY: init lint test doctor validate vault_init provision_core generate-service generate-argo-app generate-vault-secret deploy pre-merge

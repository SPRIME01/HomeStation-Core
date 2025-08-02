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

# 3️⃣.5 Deploy minimal Supabase (PostgreSQL only for testing)
deploy_supabase_minimal:
    kubectl apply -f infra/supabase/minimal-deployment.yaml
    echo "✅ Minimal Supabase deployed. Check: kubectl get pods -n supabase"

# 3️⃣.6 Check Supabase status
supabase_status:
    echo "🔍 Supabase Pods Status:"
    kubectl get pods -n supabase
    echo ""
    echo "🔍 Supabase Secrets:"
    kubectl get secrets -n supabase
    echo ""
    echo "🔍 Traefik IngressRoutes:"
    kubectl get ingressroutes -n supabase
    echo ""
    echo "🔍 ArgoCD Application Status:"
    kubectl get applications -n argocd supabase

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

# 8️⃣ Infrastructure as Code (Pulumi)
pulumi-install:
    @echo "📦 Installing Pulumi dependencies..."
    cd infrastructure/pulumi && pnpm install

pulumi-preview:
    @echo "🔍 Previewing infrastructure changes with Pulumi..."
    cd infrastructure/pulumi && bash -c 'source ../../.env && export PULUMI_CONFIG_PASSPHRASE && pulumi preview'

pulumi-up:
    @echo "🚀 Deploying infrastructure with Pulumi..."
    cd infrastructure/pulumi && bash -c 'source ../../.env && export PULUMI_CONFIG_PASSPHRASE && pulumi up'

pulumi-destroy:
    @echo "💥 Destroying infrastructure with Pulumi..."
    cd infrastructure/pulumi && bash -c 'source ../../.env && export PULUMI_CONFIG_PASSPHRASE && pulumi destroy'

pulumi-init stack:
    @echo "🏗️ Initializing Pulumi stack: {{stack}}"
    cd infrastructure/pulumi && pulumi stack init {{stack}}

pulumi-init-default:
    @echo "🏗️ Initializing default Pulumi stack: homelab-dev"
    cd infrastructure/pulumi && bash -c 'source ../../.env && export PULUMI_CONFIG_PASSPHRASE && pulumi login --local'
    cd infrastructure/pulumi && bash -c 'source ../../.env && export PULUMI_CONFIG_PASSPHRASE && pulumi stack init homelab-dev || echo "Stack already exists"'
    cd infrastructure/pulumi && bash -c 'source ../../.env && export PULUMI_CONFIG_PASSPHRASE && pulumi config set kubeconfig ~/.kube/config'

# 9️⃣ Configuration Management (Ansible)
ansible-setup:
    @echo "⚙️ Setting up homelab with Ansible..."
    cd infrastructure/ansible && bash -c 'source ../../.env && echo "$ANSIBLE_BECOME_PASSWORD" > /tmp/ansible_pass && ansible-playbook playbooks/setup.yml --become --become-password-file=/tmp/ansible_pass; rm /tmp/ansible_pass'

ansible-deploy-supabase:
    @echo "🐘 Deploying Supabase with Ansible..."
    cd infrastructure/ansible && bash -c 'source ../../.env && echo "$ANSIBLE_BECOME_PASSWORD" > /tmp/ansible_pass && ansible-playbook playbooks/deploy-supabase.yml --become --become-password-file=/tmp/ansible_pass; rm /tmp/ansible_pass'

ansible-backup:
    @echo "💾 Creating homelab backup with Ansible..."
    cd infrastructure/ansible && bash -c 'source ../../.env && echo "$ANSIBLE_BECOME_PASSWORD" > /tmp/ansible_pass && ansible-playbook playbooks/backup.yml --become --become-password-file=/tmp/ansible_pass; rm /tmp/ansible_pass'

ansible-ping:
    @echo "🏓 Testing Ansible connectivity..."
    cd infrastructure/ansible && bash -c 'source ../../.env && echo "$ANSIBLE_BECOME_PASSWORD" > /tmp/ansible_pass && ansible all -m ping --become --become-password-file=/tmp/ansible_pass; rm /tmp/ansible_pass'

# 🔟 Complete infrastructure setup
infra-init: pulumi-install pulumi-init-default ansible-setup
    @echo "🎉 Infrastructure initialization complete!"

infra-deploy: pulumi-up ansible-deploy-supabase
    @echo "🚀 Infrastructure deployment complete!"

# .PHONY: init lint test doctor validate vault_init provision_core generate-service generate-argo-app generate-vault-secret deploy pre-merge pulumi-install pulumi-preview pulumi-up pulumi-destroy pulumi-init pulumi-init-default ansible-setup ansible-deploy-supabase ansible-backup infra-init infra-deploy

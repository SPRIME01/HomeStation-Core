# ╔═══════════════════════════════════════════════════════════════╗
# ║                AI-Native Monorepo Orchestration               ║
# ║  Hexagonal/DDD Nx workspace with Python, ML, and Cloud       ║
# ║  Built for streamlined one-person dev workflow               ║
# ║  🔄 Reversible Microservice Architecture Support             ║
# ╚═══════════════════════════════════════════════════════════════╝

# Cross-platform shell configuration
# set shell := ["bash", "-c"]  # Uncomment if you need to specify shell explicitly

# Tool shortcuts and defaults
NX := "npx nx"
CTX := ""                                     # Context name for DDD operations
PROJECT := ""                                 # Project name for operations
TARGET := ""                                  # Target name for infrastructure
PLAYBOOK := ""                                # Ansible playbook name
HOSTS := ""                                   # Ansible hosts
PCT := ""                                     # Percentage for canary deployments
TRANSPORT := "fastapi"                        # Transport layer for microservices
NAMESPACE := "default"                        # Kubernetes namespace
SCALE_TARGET := "70"                          # HPA CPU target percentage

# ==============================================================================
# Configuration Variables - Adjust as needed
# ==============================================================================
PYTHON_VERSION := "3.12"
NX_PYTHON_PLUGIN_VERSION := "21.0.3"
RUST_TOOLCHAIN_UV_INSTALL := "false"
CUSTOM_PY_GEN_PLUGIN_NAME := "shared-python-tools"
CUSTOM_PY_APP_GENERATOR := "{{CUSTOM_PY_GEN_PLUGIN_NAME}}:shared-python-app"
CUSTOM_PY_LIB_GENERATOR := "{{CUSTOM_PY_GEN_PLUGIN_NAME}}:shared-python-lib"

# Service Architecture Configuration
SERVICE_GENERATOR := "@org/context-to-service"
SERVICE_REMOVER := "@org/remove-service-shell"
CONTAINER_REGISTRY := "ghcr.io/your-org"
SERVICE_BASE_PORT := "8000"

# Hexagonal Architecture Scaffolding Configuration
APPS := ""
DOMAINS := ""

# Root paths
MONOREPO_ROOT := "."
PYTHON_VENV_PATH := MONOREPO_ROOT + "/.venv"
ROOT_PYPROJECT_TOML := MONOREPO_ROOT + "/pyproject.toml"

# ==============================================================================
# Help System - Auto-generated from target comments
# ==============================================================================

def: help

help: # Show this help menu
    @echo "Available targets:"
    @just --list
    @echo ""
    @echo "🔄 Service Architecture Examples:"
    @echo "  just service-split CTX=core TRANSPORT=fastapi"
    @echo "  just service-merge CTX=core"
    @echo "  just deploy-services"
    @echo "  just scale-service CTX=core REPLICAS=3"
    @echo ""
    @echo "🏗️ Development Examples:"
    @echo "  just context-new CTX=orders      # Create DDD context"
    @echo "  just train                       # Train ML models"
    @echo "  just ci                          # Run CI pipeline"

# ==============================================================================
# Initial Setup and Environment Management
# ==============================================================================

# Core setup - lightweight installation with essentials only
setup: init-nx init-python-env-core install-custom-py-generator install-service-generators install-pre-commit
    @echo "🚀 Core monorepo setup complete!"
    @echo "📦 To install additional components:"
    @echo "  • AI/ML tools:     just setup-ai"
    @echo "  • Cloud tools:     just setup-cloud"
    @echo "  • Analytics:       just setup-analytics"
    @echo "  • All extras:      just setup-full"
    @echo "  • Help:            just help-setup"

# Full setup - everything included
setup-full: setup setup-ai setup-cloud setup-analytics setup-dev setup-database setup-web setup-supabase
    @echo "🚀 Full monorepo setup complete with all components!"

# Core Python environment (lightweight)
init-python-env-core:
    @echo "🐍 Setting up core Python environment..."
    @python3 tools/scripts/setup_helper.py init_python_env \
        --python-version="{{PYTHON_VERSION}}" \
        --root-pyproject-toml="{{ROOT_PYPROJECT_TOML}}" \
        --monorepo-root="{{MONOREPO_ROOT}}" \
        --profile=core

# Full Python environment (all dependencies)
init-python-env-full:
    @echo "🐍 Setting up full Python environment with all dependencies..."
    @python3 tools/scripts/setup_helper.py init_python_env --python-version={{PYTHON_VERSION}} --root-pyproject-toml={{ROOT_PYPROJECT_TOML}} --monorepo-root={{MONOREPO_ROOT}} --profile=full
init-nx: # Initialize Nx workspace
    @python3 tools/scripts/setup_helper.py init_nx --nx-python-plugin-version={{NX_PYTHON_PLUGIN_VERSION}}

# Modular Component Installation
# ==============================================================================

setup-ai: # Install AI/ML dependencies (PyTorch, Transformers, etc.)
    @echo "🤖 Installing AI/ML dependencies..."
    @if ! command -v uv >/dev/null 2>&1; then \
        echo "'uv' not found. Installing with pipx..."; \
        if command -v pipx >/dev/null 2>&1; then \
            pipx install uv; \
        else \
            echo "'pipx' not found. Installing 'uv' with pip..."; \
            python3 -m pip install --user uv; \
        fi \
    fi
    @uv sync --group ai

setup-cloud: # Install cloud and infrastructure dependencies
    @echo "☁️ Installing cloud dependencies..."
    @uv sync --group cloud

setup-analytics: # Install analytics and data science dependencies
    @echo "📊 Installing analytics dependencies..."
    @uv sync --group analytics

setup-dev: # Install development and testing tools
    @echo "🛠️ Installing development tools..."
    @uv sync --group dev

setup-database: # Install database dependencies
    @echo "🗄️ Installing database dependencies..."
    @uv sync --group database

setup-web: # Install web/API dependencies
    @echo "🌐 Installing web/API dependencies..."
    @uv sync --group web

setup-supabase: # Install Supabase dependencies
    @echo "🚀 Installing Supabase dependencies..."
    @uv sync --group supabase

help-setup: # Show available setup options
    @echo "🔧 Available Setup Commands:"
    @echo ""
    @echo "Core Setup:"
    @echo "  just setup           - Lightweight core installation"
    @echo "  just setup-full      - Complete installation with all components"
    @echo ""
    @echo "Component Installation:"
    @echo "  just setup-ai        - AI/ML tools (PyTorch, Transformers, Scikit-learn)"
    @echo "  just setup-cloud     - Cloud tools (Docker, Kubernetes, Pulumi)"
    @echo "  just setup-analytics - Analytics (Pandas, NumPy, Jupyter, Matplotlib)"
    @echo "  just setup-dev       - Development tools (Testing, Linting, Formatting)"
    @echo "  just setup-database  - Database tools (SQLModel, PostgreSQL, Redis)"
    @echo "  just setup-web       - Web/API tools (FastAPI, Uvicorn, Pydantic)"
    @echo "  just setup-supabase  - Supabase integration"
    @echo ""
    @echo "Environment Management:"
    @echo "  just clean-env       - Clean Python environment"
    @echo "  just reinstall       - Clean install core components"
    @echo "  just reinstall-full  - Clean install all components"

clean-env: # Clean Python environment
    @echo "🧹 Cleaning Python environment..."
    @rm -rf .venv
    @echo "✅ Environment cleaned. Run setup commands to reinstall."

reinstall: clean-env setup # Clean install core components
    @echo "♻️ Clean reinstall completed!"

reinstall-full: clean-env setup-full # Clean install everything
    @echo "♻️ Clean full reinstall completed!"

# Legacy/Compatibility Commands
# ==============================================================================

init-python-env: init-python-env-core # Backward compatibility

install-custom-py-generator: # Install custom Python generators
    @echo "🔧 Installing custom Python generators..."
    @if [ -f ".make_assets/setup_helper.sh" ]; then \
        echo "🔧 Using legacy setup_helper.sh (if available)..."; \
        bash ./.make_assets/setup_helper.sh install_custom_py_generator {{CUSTOM_PY_GEN_PLUGIN_NAME}}; \
    else \
        echo "🔧 setup_helper.sh not found, using Python-based installation..."; \
        python3 tools/scripts/setup_helper.py install_custom_py_generator --custom-py-gen-plugin-name={{CUSTOM_PY_GEN_PLUGIN_NAME}}; \
    fi

install-service-generators: # Install service architecture generators
    @echo "🔧 Installing service architecture generators..."
    @pnpm install @org/nx-service-generators || echo "⚠️  Service generators not yet available, will use built-in implementations"

install-pre-commit: # Install git pre-commit hooks
    @python3 tools/scripts/setup_helper.py install_pre_commit

# ==============================================================================
# Project Generation - Apps, Libraries, and DDD Contexts
# ==============================================================================

app NAME: # Generate Python application
    @echo "✨ Generating Python application '{{NAME}}' with custom settings..."
    pnpm nx generate {{CUSTOM_PY_APP_GENERATOR}} {{NAME}} --directory=apps
    @echo "Installing project-specific Python dependencies for {{NAME}}..."
    pnpm nx run {{NAME}}:install-deps
    @echo "🎉 Python application '{{NAME}}' generated and dependencies installed successfully."

lib NAME: # Generate Python library
    @echo "✨ Generating Python library '{{NAME}}' with custom settings..."
    pnpm nx generate {{CUSTOM_PY_LIB_GENERATOR}} {{NAME}} --directory=libs
    @echo "Installing project-specific Python dependencies for {{NAME}}..."
    pnpm nx run {{NAME}}:install-deps
    @echo "🎉 Python library '{{NAME}}' generated and dependencies installed successfully."

context-new CTX: # Create DDD context with hexagonal architecture
    @echo "🏛️ Creating DDD context '{{CTX}}' with hexagonal architecture..."
    @echo "📦 Creating domain layer..."
    {{NX}} g lib {{CTX}} --directory=libs/{{CTX}}/domain --tags=context:{{CTX}},layer:domain,deployable:false
    @echo "⚙️ Creating application layer..."
    {{NX}} g lib {{CTX}} --directory=libs/{{CTX}}/application --tags=context:{{CTX}},layer:application,deployable:false
    @echo "🔌 Creating infrastructure layer..."
    {{NX}} g lib {{CTX}} --directory=libs/{{CTX}}/infrastructure --tags=context:{{CTX}},layer:infrastructure,deployable:false
    @echo "✅ Context {{CTX}} created with hexagonal architecture and deployable:false tags."
    @echo "💡 Use 'just service-split CTX={{CTX}}' to extract as microservice when needed."

# ==============================================================================
# 🔄 Reversible Microservice Architecture Management
# ==============================================================================

service-split CTX TRANSPORT='fastapi': # Extract context to microservice
    @echo "🔧 Extracting context '{{CTX}}' to microservice with {{TRANSPORT}} transport..."
    @if echo "{{CTX}}" | grep -q '[/.\\]'; then \
        echo "❌ Invalid context name: {{CTX}}. Context names cannot contain /, \\, or ."; \
        exit 1; \
    fi
    @echo "📋 Checking if context exists..."
    @if [ ! -d "libs/{{CTX}}" ]; then \
        echo "❌ Context {{CTX}} not found. Run 'just context-new CTX={{CTX}}' first."; \
        exit 1; \
    fi
    @echo "🏗️ Creating microservice application structure..."
    @just create-service-app CTX={{CTX}} TRANSPORT={{TRANSPORT}}
    @echo "🐳 Generating container configuration..."
    @just create-service-container CTX={{CTX}}
    @echo "☸️ Generating Kubernetes manifests..."
    @just create-service-k8s CTX={{CTX}}
    @echo "🏷️ Updating deployment tags..."
    @just update-service-tags CTX={{CTX}} DEPLOYABLE=true
    @echo "✅ Context {{CTX}} extracted to microservice at apps/{{CTX}}-svc/"
    @echo "💡 Deploy with: just deploy-service CTX={{CTX}}"
service-status: # Show deployment status of all contexts
    @echo "📊 Context Deployment Status:"
    @echo "════════════════════════════════════════════════════════════════"
    @for ctx_dir in libs/*/; do \
        if [ -d "$$ctx_dir" ]; then \
            ctx=$$(basename "$$ctx_dir"); \
            if [ -f "$$ctx_dir/project.json" ]; then \
                deployable=$$(jq -r '.tags[]? | select(startswith("deployable:")) | split(":")[1]' "$$ctx_dir/project.json" 2>/dev/null || echo "false"); \
                if [ -z "$$deployable" ]; then deployable="false"; fi; \
                service_exists="❌"; \
                if [ -d "apps/$$ctx-svc" ]; then service_exists="✅"; fi; \
                printf "  %-20s deployable:%-8s service:%-3s\n" "$$ctx" "$$deployable" "$$service_exists"; \
            fi; \
        fi; \
    done
    @echo "════════════════════════════════════════════════════════════════"

service-list: # List all deployable services
    @echo "🚀 Deployable Services:"
    @{{NX}} show projects --json 2>/dev/null | jq -r '.[] | select(test("-svc$"))' | sort || find apps -name "*-svc" -type d | sed 's|apps/||g' | sort

# ==============================================================================
# AI/ML Model Lifecycle Management
# ==============================================================================

model-new CTX: # Generate new ML model library
    @echo "🤖 Creating ML model library '{{CTX}}'..."
    {{NX}} g lib {{CTX}} --directory=libs/models --tags=context:{{CTX}},type:model,deployable:false
    @echo "✅ ML model library {{CTX}} created."

train: # Train all affected ML models
    @echo "🧠 Training affected ML models..."
    {{NX}} affected --target=train --parallel

evaluate: # Evaluate affected ML models
    @echo "📊 Evaluating affected ML models..."
    {{NX}} affected --target=evaluate --parallel

register: # Register affected models in model registry
    @echo "📝 Registering affected models..."
    {{NX}} affected --target=register --parallel

promote CTX CH: # Promote model to environment
    @echo "🚀 Promoting model {{CTX}} to {{CH}}..."
    {{NX}} run libs/models/{{CTX}}:promote --to={{CH}}

canary PCT: # Canary deploy API with traffic percentage
    @echo "🐦 Canary deploying API with {{PCT}}% traffic..."
    {{NX}} run apps/api:deploy --percent {{PCT}}

# ==============================================================================
# Development Workflow - Quality Gates and CI/CD
# ==============================================================================

dev: # Start affected apps in development mode with watch
    @echo "🚀 Starting development servers..."
    {{NX}} run-many --target=serve --all --parallel

ci: # Run complete CI pipeline with service filtering
    @echo "🔄 Running CI pipeline..."
    @echo "📝 Formatting check..."
    {{NX}} format:check
    @echo "🔍 Linting affected projects..."
    {{NX}} affected -t lint --parallel=3
    @echo "🧪 Testing affected projects..."
    {{NX}} affected -t test --parallel=3
    @echo "🧪 Running e2e tests..."
    @just e2e-test
    @echo "📦 Building affected projects..."
    {{NX}} affected -t build --parallel=3
    @echo "🐳 Building deployable services..."
    @just build-services
    @echo "✅ CI pipeline completed successfully!"

ci-services: # Run CI only for deployable services
    @echo "🔄 Running CI pipeline for deployable services..."
    {{NX}} affected --target=lint,test,build --projects="tag:deployable:true" --parallel=3

build-services: # Build all deployable services
    @echo "🐳 Building deployable services..."
    @command -v jq >/dev/null 2>&1 || { \
      echo "❌ jq is required to build services. Please install jq (https://stedolan.github.io/jq/) and try again."; \
      exit 1; \
    } \
    && if {{NX}} show projects --json 2>/dev/null | jq -r '.[] | select(test("-svc$$"))' | head -1 > /dev/null 2>&1; then \
        {{NX}} run-many --target=build --projects="tag:deployable:true" --parallel=3; \
        echo "✅ All deployable services built successfully!"; \
    else \
        echo "ℹ️  No deployable services found. Use 'just service-split CTX=<name>' to create some."; \
    fi

lint: # Lint all affected projects
    @echo "🔎 Linting affected projects..."
    {{NX}} affected --target=lint --base=main --parallel=3

test: # Run tests for all affected projects
    @echo "🧪 Running tests for affected projects..."
    {{NX}} affected --target=test --base=main --parallel=3

e2e-test: # Run e2e tests
    @echo "🧪 Running e2e tests for vector-db..."
    {{NX}} e2e e2e-vector-db

build: # Build all affected projects
    @echo "📦 Building affected projects..."
    {{NX}} affected --target=build --base=main --parallel=3

serve PROJECT: # Serve specific application
    @echo "🚀 Serving '{{PROJECT}}'..."
    {{NX}} serve {{PROJECT}}

graph: # Open Nx dependency graph visualizer
    @echo "📊 Opening Nx dependency graph..."
    {{NX}} graph

# ==============================================================================
# 🐳 Container and Kubernetes Management
# ==============================================================================

containerize PROJECT: # Build Docker image for project
    @echo "🐳 Building Docker image for '{{PROJECT}}'..."
    {{NX}} run {{PROJECT}}:container
    @echo "✅ Docker image for '{{PROJECT}}' built successfully."

build-service-images: # Build Docker images for all deployable services
    @echo "🐳 Building Docker images for all deployable services..."
    @find apps -name "*-svc" -type d -print0 | \
        while IFS= read -r -d '' svc_path; do \
            svc=$$(printf '%s\n' "$$svc_path" | sed 's|apps/||g'); \
            echo "🔨 Building image for $$svc..."; \
            {{NX}} run "$$svc:docker" || echo "⚠️  Failed to build $$svc"; \
        done

deploy-service CTX: # Deploy specific service to Kubernetes
    @echo "🚀 Deploying service {{CTX}} to Kubernetes..."
    @if [ ! -d "apps/{{CTX}}-svc" ]; then \
        echo "❌ Service {{CTX}}-svc not found. Run 'just service-split CTX={{CTX}}' first."; \
        exit 1; \
    fi
    @echo "🐳 Building service image..."
    {{NX}} run {{CTX}}-svc:docker
    @echo "☸️ Applying Kubernetes manifests..."
    kubectl apply -f apps/{{CTX}}-svc/k8s/ --namespace={{NAMESPACE}}
    @echo "✅ Service {{CTX}} deployed successfully!"

deploy-services: # Deploy all deployable services to Kubernetes
    @echo "🚀 Deploying all deployable services to Kubernetes..."
    @for svc in $$(find apps -name "*-svc" -type d | sed 's|apps/||g'); do \
        echo "🚀 Deploying $$svc..."; \
        just deploy-service CTX=$${svc%-svc} || echo "⚠️  Failed to deploy $$svc"; \
    done

scale-service CTX REPLICAS: # Scale service replicas
    @echo "📈 Scaling service {{CTX}} to {{REPLICAS}} replicas..."
    kubectl scale deployment {{CTX}}-svc --replicas={{REPLICAS}} --namespace={{NAMESPACE}}
    @echo "✅ Service {{CTX}} scaled to {{REPLICAS}} replicas."

service-logs CTX: # View service logs
    @echo "📄 Viewing logs for service {{CTX}}..."
    kubectl logs -l app={{CTX}}-svc --namespace={{NAMESPACE}} --tail=100 -f

# ==============================================================================
# Infrastructure as Code (IaC) - Pulumi, Ansible, and Cloud
# ==============================================================================

infra-plan TARGET: # Run Pulumi plan
    @echo "🗺️ Running IaC plan for '{{TARGET}}'..."
    {{NX}} run infrastructure:plan-{{TARGET}}

infra-apply TARGET: # Apply Pulumi changes
    @echo "🚀 Applying IaC changes for '{{TARGET}}'..."
    {{NX}} run infrastructure:apply-{{TARGET}}

ansible-run PLAYBOOK HOSTS: # Run Ansible playbook
    @echo "⚙️ Running Ansible playbook '{{PLAYBOOK}}' on hosts '{{HOSTS}}'..."
    {{NX}} run ansible-playbooks:run-{{PLAYBOOK}} --args="--inventory {{HOSTS}}"

# ==============================================================================
# Workspace Management and Diagnostics
# ==============================================================================

cache-clear: # Clear Nx cache
    @echo "🧹 Clearing Nx cache..."
    {{NX}} reset

doctor: # Verify workspace constraints and generate dependency graph
    @echo "🩺 Running workspace diagnostics..."
    {{NX}} graph --file=diag.html && echo "📊 Dependency graph saved to diag.html"
    @echo "📋 Checking service architecture integrity..."
    @just service-status

tree: # Pretty-print current workspace layout
    @echo "📁 Current workspace structure:"
    @if command -v tree >/dev/null 2>&1; then \
        tree -I 'node_modules|__pycache__|*.pyc|.pytest_cache|.nx|dist' -L 3; \
    else \
        find . -type d -name 'node_modules' -prune -o -type d -name '__pycache__' -prune -o -type d -name '.nx' -prune -o -type d -name 'dist' -prune -o -type d -print | head -50; \
    fi

clean: # Clean build artifacts and caches (use with caution)
    @echo "🗑️ Cleaning Nx cache, node_modules, and Python environments..."
    if git rev-parse --show-toplevel >/dev/null 2>&1; then \
        PROJECT_ROOT="$(git rev-parse --show-toplevel)"; \
    else \
        echo "⚠️ Not inside a git repository. Using current directory as project root."; \
        PROJECT_ROOT="$$PWD"; \
    fi; \
    cd "$$PROJECT_ROOT"; \
    {{NX}} reset
    rm -rf "$PROJECT_ROOT/node_modules" "$PROJECT_ROOT/.venv"
    find "$PROJECT_ROOT" -name ".nx" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$PROJECT_ROOT" -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$PROJECT_ROOT" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$PROJECT_ROOT" -name "*.pyc" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
    @echo "✅ Cleanup complete. You may need to run 'just setup' again."

# ==============================================================================
# 🔧 Internal Service Management Helpers
# ==============================================================================

create-service-app CTX TRANSPORT: # Internal: Create service application structure
    @echo "🏗️ Creating service application for {{CTX}}..."
    @mkdir -p "apps/{{CTX}}-svc/src"
    @echo '"""' > "apps/{{CTX}}-svc/src/main.py"
    @echo "{{CTX}} Microservice - Auto-generated service wrapper" >> "apps/{{CTX}}-svc/src/main.py"
    @echo "Exposes libs/{{CTX}} domain logic via {{TRANSPORT}} transport" >> "apps/{{CTX}}-svc/src/main.py"
    @echo '"""' >> "apps/{{CTX}}-svc/src/main.py"
    @if [ "{{TRANSPORT}}" = "fastapi" ]; then \
        echo "from fastapi import FastAPI, Depends" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "from libs.{{CTX}}.application.{{CTX}}_service import $$(echo {{CTX}} | awk '{print toupper(substr($$0,1,1)) tolower(substr($$0,2))}')Service" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "from libs.{{CTX}}.adapters.memory_adapter import Memory$$(echo {{CTX}} | awk '{print toupper(substr($$0,1,1)) tolower(substr($$0,2))}')Adapter" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "app = FastAPI(" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "    title=\"$$(echo {{CTX}} | awk '{print toupper(substr($$0,1,1)) tolower(substr($$0,2))}') Service\"," >> "apps/{{CTX}}-svc/src/main.py"; \
        echo ")" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "if __name__ == \"__main__\":" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "    import uvicorn" >> "apps/{{CTX}}-svc/src/main.py"; \
        echo "    uvicorn.run(app, host=\"0.0.0.0\", port=8000)" >> "apps/{{CTX}}-svc/src/main.py"; \
    fi
    @echo "✅ Service application structure created for {{CTX}}."

create-service-container CTX: # Internal: Generate Docker configuration
    @echo "🐳 Creating Docker configuration for {{CTX}}..."
    @mkdir -p "apps/{{CTX}}-svc"
    @echo "FROM python:3.12-slim" > "apps/{{CTX}}-svc/Dockerfile"
    @echo "WORKDIR /app" >> "apps/{{CTX}}-svc/Dockerfile"
    @echo "COPY . ." >> "apps/{{CTX}}-svc/Dockerfile"
    @echo "RUN pip install -e ." >> "apps/{{CTX}}-svc/Dockerfile"
    @echo "EXPOSE 8000" >> "apps/{{CTX}}-svc/Dockerfile"
    @echo "CMD [\"uvicorn\", \"src.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]" >> "apps/{{CTX}}-svc/Dockerfile"
    @echo "✅ Docker configuration created for {{CTX}}."

create-service-k8s CTX: # Internal: Generate Kubernetes manifests
    @echo "☸️ Creating Kubernetes manifests for {{CTX}}..."
    @mkdir -p "apps/{{CTX}}-svc/k8s"
    @echo "apiVersion: apps/v1" > "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "kind: Deployment" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "metadata:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "  name: {{CTX}}-svc" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "spec:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "  replicas: 1" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "  selector:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "    matchLabels:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "      app: {{CTX}}-svc" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "  template:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "    metadata:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "      labels:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "        app: {{CTX}}-svc" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "    spec:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "      containers:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "      - name: {{CTX}}-svc" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "        image: {{CONTAINER_REGISTRY}}/{{CTX}}-svc:latest" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "        ports:" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "        - containerPort: 8000" >> "apps/{{CTX}}-svc/k8s/deployment.yaml"
    @echo "✅ Kubernetes manifests created for {{CTX}}."

update-service-tags CTX DEPLOYABLE: # Internal: Update deployable tags for a context
    @echo "🏷️ Updating deployable tags for context {{CTX}} to {{DEPLOYABLE}}..."
    @python3 tools/scripts/setup_helper.py update_service_tags --ctx={{CTX}} --deployable={{DEPLOYABLE}}

# ==============================================================================
# Original HomeStation_Core Commands (Preserved)
# ==============================================================================

# Start the FastAPI development server
dev-original:
    cd apps/core-api && uv run uvicorn main:app --reload --host 0.0.0.0

# Run Ruff linter and MyPy type checker on all code
lint-original:
    uv run ruff check libs apps tools
    uv run mypy libs apps tools

# Run the automated test suite
test-original:
    uv run pytest libs apps tools

# Format all Python code using Ruff
format-original:
    uv run ruff format libs apps tools

# Check import boundaries and ensure hexagonal layering rules
validate:
    uv run python tools/scripts/validate_hexagon.py

# Build a Docker image for the default context's microservice
build-service:
    pnpm nx run core-svc:docker

# Train an ML model for the default context's microservice
train-original:
    pnpm nx run core-svc:train

# Promote the trained model to production for the default context's microservice
promote-original:
    pnpm nx run core-svc:promote

# Deploy the default context's microservice
deploy-original:
    pnpm nx run core-svc:deploy

# Generate project documentation (stub)
docs:
    uv run python tools/scripts/generate_docs.py

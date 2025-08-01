#!/usr/bin/env bash
# Test for 'just deploy' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/deploy-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# Common vars
NAMESPACE ?= dev

# 6️⃣ Deploy to cluster (push manifests, ArgoCD sync)
deploy:
    git push origin HEAD
    bash scripts/argo-sync.sh $(NAMESPACE)

.PHONY: deploy
EOF

# Create scripts directory and argo-sync.sh
mkdir -p scripts
cat > scripts/argo-sync.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=$1
echo "Waiting for ArgoCD applications to sync in namespace ${NAMESPACE} ..."
kubectl -n argocd wait --for=condition=Synced applications --all --timeout=600s
EOF
chmod +x scripts/argo-sync.sh

# Initialize a git repo for testing
git init
git config user.name "Test User"
git config user.email "test@example.com"
git add .
git commit -m "Initial commit"

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/deploy-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "git" "$WRAPPER_DIR"
create_mock_wrapper "bash" "$WRAPPER_DIR"
create_mock_wrapper "kubectl" "$WRAPPER_DIR"

test_deploy_command() {
    # Run the deploy command (mocked)
    run_test "deploy command should push to git and sync with ArgoCD" test_deploy_process
}

test_deploy_process() {
    # Run just deploy with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just deploy 2>&1)
    PATH="$original_path"

    # Check that git was called to push
    assert_file_exists "$WRAPPER_DIR/git_calls.log" "git calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/git_calls.log" "git push origin HEAD" "git should push to origin"

    # Check that bash was called to run argo-sync.sh
    assert_file_exists "$WRAPPER_DIR/bash_calls.log" "bash calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/bash_calls.log" "bash scripts/argo-sync.sh dev" "argo-sync.sh should be called with correct namespace"

    # Check that kubectl was called to wait for sync
    assert_file_exists "$WRAPPER_DIR/kubectl_calls.log" "kubectl calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/kubectl_calls.log" "kubectl -n argocd wait --for=condition=Synced applications --all --timeout=600s" "kubectl should wait for applications to sync"
}

# Run the test
test_deploy_command

# Print summary
print_summary

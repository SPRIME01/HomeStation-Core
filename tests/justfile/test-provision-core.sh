#!/usr/bin/env bash
# Test for 'just provision core' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/provision-core-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# Common vars
NAMESPACE ?= dev

# 4️⃣ Provision core stack (Traefik, ArgoCD, Supabase, etc.) via Argo "app of apps"
provision core:
    kubectl apply -f infra/argocd/bootstrap.yaml
    echo "⌛ Waiting for ArgoCD sync..."
    nx run infra:wait --verbose

.PHONY: provision core
EOF

# Create infra directory and bootstrap.yaml
mkdir -p infra/argocd
cat > infra/argocd/bootstrap.yaml << 'EOF'
# Mock bootstrap YAML
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/provision-core-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "kubectl" "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"

test_provision_core_command() {
    # Run the provision core command (mocked)
    run_test "provision core command should apply bootstrap and wait for sync" test_provision_core_process
}

test_provision_core_process() {
    # Run just provision core with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just "provision core" 2>&1)
    PATH="$original_path"

    # Check that kubectl was called to apply bootstrap
    assert_file_exists "$WRAPPER_DIR/kubectl_calls.log" "kubectl calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/kubectl_calls.log" "kubectl apply -f infra/argocd/bootstrap.yaml" "kubectl should apply bootstrap"

    # Check that nx was called to wait for sync
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx run infra:wait --verbose" "nx should wait for infra sync"

    # Check that the command outputs wait message
    assert_output_contains "echo '$output'" "Waiting for ArgoCD sync" "command should output wait message"
}

# Run the test
test_provision_core_command

# Print summary
print_summary

#!/usr/bin/env bash
# Test for 'just generate argo-app' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/generate-argo-app-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# Common vars
NAMESPACE ?= dev

generate argo-app name= src=:
    nx g @org/nx-homelab-plugin:argo-app --name "{{name}}" --source "{{src}}" --namespace $(NAMESPACE)

.PHONY: generate argo-app
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/generate-argo-app-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"

test_generate_argo_app_command() {
    # Run the generate argo-app command (mocked)
    run_test "generate argo-app command should generate a new ArgoCD app" test_generate_argo_app_process
}

test_generate_argo_app_process() {
    # Run just generate argo-app with test parameters
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just "generate argo-app" "test-app" "https://github.com/test/repo" 2>&1)
    PATH="$original_path"

    # Check that nx was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx g @org/nx-homelab-plugin:argo-app --name \"test-app\" --source \"https://github.com/test/repo\" --namespace dev" "nx should generate argo-app with correct parameters"

    # Check that the argo-app directory was created
    assert_directory_exists "infra/argocd/test-app" "argo-app directory should be created"

    # Check that argo-app files were created
    assert_file_exists "infra/argocd/test-app/README.md" "argo-app README should be created"
    assert_file_exists "infra/argocd/test-app/application.yaml" "argo-app application.yaml should be created"

    # Check content of application.yaml
    assert_output_contains "cat infra/argocd/test-app/application.yaml" "name: test-app" "application.yaml should contain correct app name"
    assert_output_contains "cat infra/argocd/test-app/application.yaml" "repoURL: https://github.com/test/repo" "application.yaml should contain correct repo URL"
    assert_output_contains "cat infra/argocd/test-app/application.yaml" "namespace: dev" "application.yaml should contain correct namespace"
}

# Run the test
test_generate_argo_app_command

# Print summary
print_summary

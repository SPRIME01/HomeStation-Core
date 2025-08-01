#!/usr/bin/env bash
# Test for 'just vault:init' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/vault-init-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# 3️⃣ Bootstrap secrets backend (HashiCorp Vault in K3s)
vault:init:
    kubectl -n vault rollout status deploy/vault
    kubectl -n vault exec -it deploy/vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > vault-init.json
    jq -r '.unseal_keys_b64[0]' vault-init.json | kubectl -n vault exec -it deploy/vault -- vault operator unseal -
    echo "Vault initialised & unsealed✅"

.PHONY: vault:init
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/vault-init-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "kubectl" "$WRAPPER_DIR"
create_mock_wrapper "jq" "$WRAPPER_DIR"

test_vault_init_command() {
    # Run the vault:init command (mocked)
    run_test "vault:init command should initialize and unseal Vault" test_vault_init_process
}

test_vault_init_process() {
    # Run just vault:init with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just "vault:init" 2>&1)
    PATH="$original_path"

    # Check that kubectl was called for rollout status
    assert_file_exists "$WRAPPER_DIR/kubectl_calls.log" "kubectl calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/kubectl_calls.log" "kubectl -n vault rollout status deploy/vault" "kubectl should check vault rollout status"

    # Check that kubectl was called for vault init
    assert_output_contains "cat $WRAPPER_DIR/kubectl_calls.log" "kubectl -n vault exec -it deploy/vault -- vault operator init" "kubectl should init vault"

    # Check that vault-init.json was created
    assert_file_exists "vault-init.json" "vault-init.json should be created"

    # Check that jq was called to extract unseal key
    assert_file_exists "$WRAPPER_DIR/jq_calls.log" "jq calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/jq_calls.log" "jq -r .unseal_keys_b64[0] vault-init.json" "jq should extract unseal key"

    # Check that kubectl was called for vault unseal
    assert_output_contains "cat $WRAPPER_DIR/kubectl_calls.log" "kubectl -n vault exec -it deploy/vault -- vault operator unseal -" "kubectl should unseal vault"

    # Check that the command outputs success message
    assert_output_contains "echo '$output'" "Vault initialised & unsealed" "command should output success message"
}

# Run the test
test_vault_init_command

# Print summary
print_summary

#!/usr/bin/env bash
# Test for 'just generate vault-secret' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/generate-vault-secret-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

generate vault-secret path= policy=:
    nx g @org/nx-homelab-plugin:vault-secret --path "{{path}}" --policy "{{policy}}"

.PHONY: generate vault-secret
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/generate-vault-secret-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"

test_generate_vault_secret_command() {
    # Run the generate vault-secret command (mocked)
    run_test "generate vault-secret command should generate a new vault secret" test_generate_vault_secret_process
}

test_generate_vault_secret_process() {
    # Run just generate vault-secret with test parameters
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just "generate vault-secret" "secret/myapp/database" "read" 2>&1)
    PATH="$original_path"

    # Check that nx was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx g @org/nx-homelab-plugin:vault-secret --path \"secret/myapp/database\" --policy \"read\"" "nx should generate vault-secret with correct parameters"

    # Check that the vault-secret directory was created (with / replaced by _)
    assert_directory_exists "infra/vault-policies/secret_myapp_database" "vault-secret directory should be created"

    # Check that vault-secret files were created
    assert_file_exists "infra/vault-policies/secret_myapp_database/policy.hcl" "vault-secret policy.hcl should be created"

    # Check content of policy.hcl
    assert_output_contains "cat infra/vault-policies/secret_myapp_database/policy.hcl" "path \"secret/myapp/database\"" "policy.hcl should contain correct path"
    assert_output_contains "cat infra/vault-policies/secret_myapp_database/policy.hcl" "capabilities = [\"read\"]" "policy.hcl should contain correct policy"
}

# Run the test
test_generate_vault_secret_command

# Print summary
print_summary

#!/usr/bin/env bash
# Test for 'just generate service' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/generate-service-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# 5️⃣ Generate new artefacts using Nx plugin wrappers
generate service name=:
    nx g @org/nx-homelab-plugin:service --name "{{name}}"

.PHONY: generate service
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/generate-service-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"

test_generate_service_command() {
    # Run the generate service command (mocked)
    run_test "generate service command should generate a new service" test_generate_service_process
}

test_generate_service_process() {
    # Run just generate service with a test name
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just "generate service" "test-service" 2>&1)
    PATH="$original_path"

    # Check that nx was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx g @org/nx-homelab-plugin:service --name \"test-service\"" "nx should generate service with correct name"

    # Check that the service directory was created
    assert_directory_exists "apps/test-service" "service directory should be created"

    # Check that service files were created
    assert_file_exists "apps/test-service/README.md" "service README should be created"
    assert_file_exists "apps/test-service/index.js" "service index.js should be created"
}

# Run the test
test_generate_service_command

# Print summary
print_summary

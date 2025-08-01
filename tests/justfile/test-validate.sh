#!/usr/bin/env bash
# Test for 'just validate' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/validate-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# Common vars
NAMESPACE ?= dev

# 2️⃣ Validate cluster health & lint code
validate: lint test doctor

lint:
    nx format:check
    pnpm run eslint

test:
    nx run-many --target=test --all

doctor:
    bash scripts/doctor.sh $(KUBECONFIG)

.PHONY: validate lint test doctor
EOF

# Create scripts directory and doctor.sh
mkdir -p scripts
cat > scripts/doctor.sh << 'EOF'
#!/usr/bin/env bash
echo "Doctor check passed"
EOF
chmod +x scripts/doctor.sh

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/validate-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"
create_mock_wrapper "pnpm" "$WRAPPER_DIR"
create_mock_wrapper "bash" "$WRAPPER_DIR"

test_validate_command() {
    # Run the validate command (mocked)
    run_test "validate command should call lint, test, and doctor" test_validate_calls_all_commands
}

test_validate_calls_all_commands() {
    # Run just validate with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just validate 2>&1)
    PATH="$original_path"

    # Check that lint commands were called
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx format:check" "nx format:check should be called"

    assert_file_exists "$WRAPPER_DIR/pnpm_calls.log" "pnpm calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/pnpm_calls.log" "pnpm run eslint" "pnpm run eslint should be called"

    # Check that test command was called
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx run-many --target=test --all" "nx test should be called"

    # Check that doctor command was called
    assert_file_exists "$WRAPPER_DIR/bash_calls.log" "bash calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/bash_calls.log" "bash scripts/doctor.sh" "doctor script should be called"
}

# Run the test
test_validate_command

# Print summary
print_summary

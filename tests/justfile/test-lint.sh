#!/usr/bin/env bash
# Test for 'just lint' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/lint-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

lint:
    nx format:check
    pnpm run eslint

.PHONY: lint
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/lint-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"
create_mock_wrapper "pnpm" "$WRAPPER_DIR"

test_lint_command() {
    # Run the lint command (mocked)
    run_test "lint command should call nx format:check and pnpm run eslint" test_lint_calls_commands
}

test_lint_calls_commands() {
    # Run just lint with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just lint 2>&1)
    PATH="$original_path"

    # Check that nx was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx format:check" "nx format:check should be called"

    # Check that pnpm was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/pnpm_calls.log" "pnpm calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/pnpm_calls.log" "pnpm run eslint" "pnpm run eslint should be called"
}

# Run the test
test_lint_command

# Print summary
print_summary

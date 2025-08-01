#!/usr/bin/env bash
# Test for 'just test' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/test-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

test:
    nx run-many --target=test --all

.PHONY: test
EOF

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/test-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"

test_test_command() {
    # Run the test command (mocked)
    run_test "test command should call nx run-many --target=test --all" test_test_calls_commands
}

test_test_calls_commands() {
    # Run just test with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just test 2>&1)
    PATH="$original_path"

    # Check that nx was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/nx_calls.log" "nx calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/nx_calls.log" "nx run-many --target=test --all" "nx test should be called"

    # Check that the output contains test results
    assert_output_contains "echo '$output'" "Test results:" "output should contain test results"
    assert_output_contains "echo '$output'" "apps/app1: passed" "output should contain app1 test result"
    assert_output_contains "echo '$output'" "apps/app2: passed" "output should contain app2 test result"
    assert_output_contains "echo '$output'" "libs/lib1: passed" "output should contain lib1 test result"
}

# Run the test
test_test_command

# Print summary
print_summary

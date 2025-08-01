#!/usr/bin/env bash
# Test for 'just pre-merge' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/pre-merge-test"
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

# 7️⃣ Quality gate for merges
pre-merge: validate

.PHONY: validate lint test doctor pre-merge
EOF

# Create scripts directory and doctor.sh
mkdir -p scripts
cat > scripts/doctor.sh << 'EOF'
#!/usr/bin/env bash
echo "Doctor check passed"
EOF
chmod +x scripts/doctor.sh

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/pre-merge-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "nx" "$WRAPPER_DIR"
create_mock_wrapper "pnpm" "$WRAPPER_DIR"
create_mock_wrapper "bash" "$WRAPPER_DIR"

test_pre_merge_command() {
    # Run the pre-merge command (mocked)
    run_test "pre-merge command should call validate" test_pre_merge_calls_validate
}

test_pre_merge_calls_validate() {
    # Run just pre-merge with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just "pre-merge" 2>&1)
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
test_pre_merge_command

# Print summary
print_summary

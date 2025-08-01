#!/usr/bin/env bash
# Test for 'just init' command

set +euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/init-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# 1️⃣ Initialise workspace (node+pnpm, husky, commitlint, pre-commit)
init:
    sh -c "npm i -g nx pnpm@latest"
    sh -c "pnpm install"
    sh -c "git config core.hooksPath .husky"
EOF

# Create a minimal package.json for pnpm
cat > package.json << 'EOF'
{
  "name": "test-init",
  "version": "1.0.0",
  "private": true
}
EOF

# Create a minimal .husky directory
mkdir -p .husky

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/init-test-wrappers"
mkdir -p "$WRAPPER_DIR"

create_mock_wrapper "npm" "$WRAPPER_DIR"
create_mock_wrapper "pnpm" "$WRAPPER_DIR"
create_mock_wrapper "git" "$WRAPPER_DIR"

# Prepend WRAPPER_DIR to PATH for all just invocations
export PATH="$WRAPPER_DIR:$PATH"

test_init_command() {
    # Run the init command (mocked)
    run_test "init command should call npm, pnpm, and git" test_init_calls_commands
}

test_init_calls_commands() {
    echo "Debug: PATH before just init: $PATH"
    echo "Debug: which npm: $(which npm)"
    echo "Debug: which pnpm: $(which pnpm)"
    echo "Debug: which git: $(which git)"
    echo "Debug: Starting test_init_calls_commands"
    # Run just init with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    export npm="$WRAPPER_DIR/npm"
    export pnpm="$WRAPPER_DIR/pnpm"
    export git="$WRAPPER_DIR/git"
    echo "Debug: Running just init"
    output=$(just init 2>&1)
    echo "Debug: just init completed"
    PATH="$original_path"
    unset npm pnpm git

    # Check that npm was called with the right arguments
    echo "Debug: Checking npm log"
    assert_file_exists "$WRAPPER_DIR/npm_calls.log" "npm calls log should exist"
    echo "Debug: npm log content:"
    cat "$WRAPPER_DIR/npm_calls.log"
    echo "Debug: About to call assert_output_contains for npm"
    assert_output_contains "cat $WRAPPER_DIR/npm_calls.log" "npm i -g nx pnpm@latest" "npm should be called to install nx and pnpm"
    echo "Debug: assert_output_contains for npm completed"

    # Check that pnpm was called with the right arguments
    echo "Debug: Checking pnpm log"
    assert_file_exists "$WRAPPER_DIR/pnpm_calls.log" "pnpm calls log should exist"
    echo "Debug: pnpm log content:"
    cat "$WRAPPER_DIR/pnpm_calls.log"
    echo "Debug: About to call assert_output_contains for pnpm"
    assert_output_contains "cat $WRAPPER_DIR/pnpm_calls.log" "pnpm install" "pnpm should be called to install dependencies"
    echo "Debug: assert_output_contains for pnpm completed"

    # Check that git was called with the right arguments
    echo "Debug: Checking git log"
    assert_file_exists "$WRAPPER_DIR/git_calls.log" "git calls log should exist"
    echo "Debug: git log content:"
    cat "$WRAPPER_DIR/git_calls.log"
    echo "Debug: About to call assert_output_contains for git"
    assert_output_contains "cat $WRAPPER_DIR/git_calls.log" "git config core.hooksPath .husky" "git should be called to configure hooks path"
    echo "Debug: assert_output_contains for git completed"
    echo "Debug: All assertions completed"
}

# Run the test
echo "Debug: About to call test_init_command"
test_init_command
echo "Debug: test_init_command completed"

# Print summary
echo "Debug: About to call print_summary"
print_summary
echo "Debug: print_summary completed"

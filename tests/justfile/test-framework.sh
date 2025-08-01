#!/usr/bin/env bash
# Test framework for justfile commands



# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Test directory
TEST_DIR="/tmp/justfile-tests"
mkdir -p "$TEST_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

# Create mock command wrapper
create_mock_wrapper() {
    local command_name="$1"
    local wrapper_dir="$2"

# Write a wrapper that logs the full command line as expected by the tests
    cat > "$wrapper_dir/$command_name" << 'EOF'
#!/usr/bin/env bash
# Log the full command line as a single string, matching what the test expects
echo "$0 $*" >> "$wrapper_dir/$(basename "$0")_calls.log"
# Execute the real command if it exists, otherwise just log
if command -v "real_$(basename "$0")" >/dev/null 2>&1; then
    "real_$(basename "$0")" "$@"
else
    # For testing purposes, we'll just echo success for known commands
    case "$(basename "$0")" in
        npm)
            if [[ "$*" == "i -g nx pnpm@latest" ]]; then
                echo "npm install successful"
            fi
            ;;
        pnpm)
            if [[ "$*" == "install" ]]; then
                echo "pnpm install successful"
            elif [[ "$*" == "run eslint" ]]; then
                echo "pnpm eslint successful"
            fi
            ;;
        git)
            if [[ "$*" == "config core.hooksPath .husky" ]]; then
                echo "git config successful"
            fi
            ;;
        nx)
            if [[ "$*" == "format:check" ]]; then
                echo "nx format check successful"
            elif [[ "$*" == "run-many --target=test --all" ]]; then
                echo "nx test successful"
            elif [[ "$*" == "run infra:wait --verbose" ]]; then
                echo "nx infra wait successful"
            elif [[ "$*" == "g @org/nx-homelab-plugin:service --name"* ]]; then
                echo "nx generate service successful"
            elif [[ "$*" == "g @org/nx-homelab-plugin:argo-app --name"* ]]; then
                echo "nx generate argo-app successful"
            elif [[ "$*" == "g @org/nx-homelab-plugin:vault-secret --path"* ]]; then
                echo "nx generate vault-secret successful"
            fi
            ;;
        kubectl)
            if [[ "$*" == "-n vault rollout status deploy/vault" ]]; then
                echo "vault deployment found"
            elif [[ "$*" == "-n vault exec -it deploy/vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json" ]]; then
                echo '{"unseal_keys_b64":["mock-unseal-key"]}' > "$wrapper_dir/../vault-init.json"
                echo "vault init successful"
            elif [[ "$*" == "-n vault exec -it deploy/vault -- vault operator unseal -" ]]; then
                echo "vault unseal successful"
            elif [[ "$*" == "apply -f infra/argocd/bootstrap.yaml" ]]; then
                echo "bootstrap applied successfully"
            elif [[ "$*" == "-n argocd wait --for=condition=Synced applications --all --timeout=600s" ]]; then
                echo "applications synced successfully"
            elif [[ "$*" == "--kubeconfig"* ]]; then
                echo "✅"
            fi
            ;;
        jq)
            if [[ "$*" == "-r .unseal_keys_b64[0] vault-init.json" ]]; then
                echo "mock-unseal-key"
            fi
            ;;
        bash)
            if [[ "$*" == "scripts/doctor.sh"* ]]; then
                echo "Doctor check: Traefik...✅"
                echo "Doctor check: Argo CD...✅"
                echo "Doctor check: Vault...✅"
                echo "Doctor check: Supabase...✅"
            elif [[ "$*" == "scripts/argo-sync.sh"* ]]; then
                echo "ArgoCD sync completed"
            fi
            ;;
    esac
fi
EOF
    chmod +x "$wrapper_dir/$command_name"
}

# Assert functions
assert_file_exists() {
    local file="$1"
    local test_name="$2"
    echo "Debug: assert_file_exists - checking file: $file"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $test_name: File exists ($file)"
        ((PASSED++))
        echo "Debug: assert_file_exists - PASSED incremented to: $PASSED"
    else
        echo -e "${RED}✗${NC} $test_name: File does not exist ($file)"
        FAILED=$((FAILED + 1))
        echo "Debug: assert_file_exists - FAILED incremented to: $FAILED"
    fi
}

assert_directory_exists() {
    local dir="$1"
    local test_name="$2"
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $test_name: Directory exists ($dir)"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name: Directory does not exist ($dir)"
        FAILED=$((FAILED + 1))
    fi
}

assert_command_succeeds() {
    local command="$1"
    local test_name="$2"
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name: Command succeeds ($command)"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name: Command fails ($command)"
        FAILED=$((FAILED + 1))
    fi
}

assert_command_fails() {
    local command="$1"
    local test_name="$2"
    if ! eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name: Command fails as expected ($command)"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name: Command succeeds but should fail ($command)"
        FAILED=$((FAILED + 1))
    fi
}

assert_output_contains() {
    local command="$1"
    local expected="$2"
    local test_name="$3"
    local output
    output=$(eval "$command" 2>&1)
    echo "Debug: assert_output_contains - command: '$command'"
    echo "Debug: assert_output_contains - expected: '$expected'"
    echo "Debug: assert_output_contains - actual output: '$output'"
    if echo "$output" | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC} $test_name: Output contains expected text"
        ((PASSED++))
        echo "Debug: assert_output_contains - PASSED incremented to: $PASSED"
    else
        echo -e "${RED}✗${NC} $test_name: Output does not contain expected text"
        echo "Expected: $expected"
        echo "Actual: $output"
        FAILED=$((FAILED + 1))
        echo "Debug: assert_output_contains - FAILED incremented to: $FAILED"
    fi
}

assert_output_not_contains() {
    local command="$1"
    local expected="$2"
    local test_name="$3"
    local output
    output=$(eval "$command" 2>&1)
    if ! echo "$output" | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC} $test_name: Output does not contain unexpected text"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name: Output contains unexpected text"
        echo "Unexpected: $expected"
        echo "Actual: $output"
        FAILED=$((FAILED + 1))
    fi
}

# Test runner
run_test() {
    local test_name="$1"
    local test_function="$2"
    echo -e "${YELLOW}Running test:${NC} $test_name"
    echo "Debug: About to call test function: $test_function"
    "$test_function"
    echo "Debug: Test function completed"
    echo ""
}

# Summary function
print_summary() {
    echo "===== TEST SUMMARY ====="
    echo -e "${GREEN}Passed:${NC} $PASSED"
    echo -e "${RED}Failed:${NC} $FAILED"
    echo "Total: $((PASSED + FAILED))"

    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}

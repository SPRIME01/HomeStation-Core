#!/usr/bin/env bash
# Main test runner for all justfile commands

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_TESTS=0

# Test directory
TEST_DIR="/tmp/justfile-tests-all"
mkdir -p "$TEST_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

# Run a single test script
run_test_script() {
    local test_script="$1"
    local test_name="$2"

    echo -e "${BLUE}Running test suite:${NC} $test_name"
    echo "=============================================="

    # Run the test script and capture output
    local output
    local exit_code=0
    output=$(bash "$test_script" 2>&1) || true

    # Display output
    echo "$output"
    echo ""

    # Parse results from output
    if [[ "$output" == *"All tests passed!"* ]]; then
        echo -e "${GREEN}✓ Test suite passed:${NC} $test_name"
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
        echo -e "${RED}✗ Test suite failed:${NC} $test_name"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
}

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run all test scripts
echo -e "${YELLOW}Starting comprehensive justfile test suite${NC}"
echo "=================================================="
echo ""

run_test_script "$SCRIPT_DIR/test-init.sh" "Init Command"
run_test_script "$SCRIPT_DIR/test-lint.sh" "Lint Command"
run_test_script "$SCRIPT_DIR/test-test.sh" "Test Command"
run_test_script "$SCRIPT_DIR/test-doctor.sh" "Doctor Command"
run_test_script "$SCRIPT_DIR/test-validate.sh" "Validate Command"
run_test_script "$SCRIPT_DIR/test-vault-init.sh" "Vault Init Command"
run_test_script "$SCRIPT_DIR/test-provision-core.sh" "Provision Core Command"
run_test_script "$SCRIPT_DIR/test-generate-service.sh" "Generate Service Command"
run_test_script "$SCRIPT_DIR/test-generate-argo-app.sh" "Generate Argo App Command"
run_test_script "$SCRIPT_DIR/test-generate-vault-secret.sh" "Generate Vault Secret Command"
run_test_script "$SCRIPT_DIR/test-deploy.sh" "Deploy Command"
run_test_script "$SCRIPT_DIR/test-pre-merge.sh" "Pre-Merge Command"

# Print final summary
echo -e "${YELLOW}Final Test Summary${NC}"
echo "=================="
echo -e "${GREEN}Passed:${NC} $TOTAL_PASSED/$TOTAL_TESTS test suites"
echo -e "${RED}Failed:${NC} $TOTAL_FAILED/$TOTAL_TESTS test suites"

if [[ $TOTAL_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All test suites passed!${NC}"
    exit 0
else
    echo -e "${RED}Some test suites failed!${NC}"
    exit 1
fi

#!/usr/bin/env bash
# Test for 'just doctor' command

set -euo pipefail

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-framework.sh"

# Test setup
TEST_REPO_DIR="$TEST_DIR/doctor-test"
mkdir -p "$TEST_REPO_DIR"
cd "$TEST_REPO_DIR"

# Create a minimal justfile for testing
cat > justfile << 'EOF'
set dotenv-load

# Common vars
KUBECONFIG := $(HOME)/.kube/config

doctor:
    bash scripts/doctor.sh $(KUBECONFIG)

.PHONY: doctor
EOF

# Create scripts directory and doctor.sh
mkdir -p scripts
cat > scripts/doctor.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
KCFG=$1

sections=("Traefik" "Argo CD" "Vault" "Supabase")
for s in "${sections[@]}"; do
  printf "♻️  Checking %s..." "$s"
  kubectl --kubeconfig "$KCFG" get deploy "$s" -A &>/dev/null && echo "✅" || echo "❌"
done
EOF
chmod +x scripts/doctor.sh

# Create mock wrappers
WRAPPER_DIR="$TEST_DIR/doctor-test-wrappers"
mkdir -p "$WRAPPER_DIR"
create_mock_wrapper "bash" "$WRAPPER_DIR"
create_mock_wrapper "kubectl" "$WRAPPER_DIR"

test_doctor_command() {
    # Run the doctor command (mocked)
    run_test "doctor command should call doctor.sh script" test_doctor_calls_script
}

test_doctor_calls_script() {
    # Run just doctor with mocked commands
    local original_path="$PATH"
    PATH="$WRAPPER_DIR:$PATH"
    output=$(just doctor 2>&1)
    PATH="$original_path"

    # Check that bash was called with the right arguments
    assert_file_exists "$WRAPPER_DIR/bash_calls.log" "bash calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/bash_calls.log" "bash scripts/doctor.sh" "doctor script should be called"

    # Check that kubectl was called for each service
    assert_file_exists "$WRAPPER_DIR/kubectl_calls.log" "kubectl calls log should exist"
    assert_output_contains "cat $WRAPPER_DIR/kubectl_calls.log" "kubectl --kubeconfig" "kubectl should check services"
}

# Run the test
test_doctor_command

# Print summary
print_summary

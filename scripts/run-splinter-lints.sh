#!/bin/bash
# Supabase Splinter Linting Script
# This script runs Splinter lints against your Supabase database

echo "🔍 Running Supabase Splinter Lints..."
echo "=================================="

# Run all lint views and display results
echo "Running all lint checks..."

# Function to run a specific lint
run_lint() {
    local lint_name=$1
    local result=$(kubectl exec -n supabase postgres-simple-66d8fc6874-4wscm -- psql -U postgres -d postgres -t -c "SELECT COUNT(*) FROM lint.\"$lint_name\";")
    local count=$(echo $result | xargs)
    
    if [ "$count" -gt 0 ]; then
        echo "⚠️  $lint_name: $count issues found"
        kubectl exec -n supabase postgres-simple-66d8fc6874-4wscm -- psql -U postgres -d postgres -c "SELECT title, level, detail FROM lint.\"$lint_name\";"
        echo ""
    else
        echo "✅ $lint_name: No issues"
    fi
}

# Array of all lint checks
lints=(
    "0001_unindexed_foreign_keys"
    "0002_auth_users_exposed"
    "0003_auth_rls_initplan"
    "0004_no_primary_key"
    "0005_unused_index"
    "0006_multiple_permissive_policies"
    "0007_policy_exists_rls_disabled"
    "0008_rls_enabled_no_policy"
    "0009_duplicate_index"
    "0010_security_definer_view"
    "0011_function_search_path_mutable"
    "0013_rls_disabled_in_public"
    "0014_extension_in_public"
    "0015_rls_references_user_metadata"
    "0016_materialized_view_in_api"
    "0017_foreign_table_in_api"
    "0018_unsupported_reg_types"
    "0019_insecure_queue_exposed_in_api"
    "0020_table_bloat"
    "0021_fkey_to_auth_unique"
    "0022_extension_versions_outdated"
)

# Run all lints
echo ""
echo "Running comprehensive lint analysis..."
echo "===================================="

for lint in "${lints[@]}"; do
    run_lint "$lint"
done

echo ""
echo "🎯 Lint analysis complete!"
echo ""
echo "💡 To view detailed remediation advice:"
echo "   - Check the Supabase Studio Advisors section at http://localhost:30080"
echo "   - Or run: kubectl exec -n supabase postgres-simple-66d8fc6874-4wscm -- psql -U postgres -d postgres -c \"SELECT * FROM lint.\\\"LINT_NAME\\\";\""
echo ""
)
PORTFORWARD_PID=$!

# Wait for port forward to be ready
sleep 3

# Check if PostgreSQL client is available
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL client not found. Installing..."
    sudo apt update && sudo apt install -y postgresql-client
fi

# Download latest Splinter if not present
if [ ! -f "splinter.sql" ]; then
    echo "📥 Downloading latest Splinter lints..."
    curl -o splinter.sql https://raw.githubusercontent.com/supabase/splinter/main/splinter.sql
fi

# Install and run lints
echo "🚀 Installing Splinter lints..."
psql "postgres://postgres:postgres@localhost:5433/postgres" -f splinter.sql

echo "🔍 Running all lints..."
psql "postgres://postgres:postgres@localhost:5433/postgres" -c "
SELECT 
    name,
    title,
    level,
    categories,
    description
FROM lint.all_lints()
ORDER BY level, name;
"

# Cleanup
kill $PORTFORWARD_PID 2>/dev/null || true

echo "✅ Linting complete!"

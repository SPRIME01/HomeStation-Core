#!/bin/bash

# Script to install Splinter lints into PostgreSQL database

set -e

echo "Installing Splinter lints..."

# Create the lint schema if it doesn't exist
kubectl exec -n supabase postgres-simple-66d8fc6874-4wscm -- psql -U postgres -d postgres -c "
CREATE SCHEMA IF NOT EXISTS lint;
"

# Download and install each lint view individually
declare -a lints=(
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

for lint in "${lints[@]}"; do
    echo "Installing lint: $lint"
    curl -s "https://raw.githubusercontent.com/supabase/splinter/main/lints/${lint}.sql" | \
    kubectl exec -i -n supabase postgres-simple-66d8fc6874-4wscm -- psql -U postgres -d postgres
done

echo "Splinter installation complete!"

# Test that lints are working
echo "Testing lint installation..."
kubectl exec -n supabase postgres-simple-66d8fc6874-4wscm -- psql -U postgres -d postgres -c "
SELECT COUNT(*) as lint_views_installed FROM pg_views WHERE schemaname = 'lint';
"

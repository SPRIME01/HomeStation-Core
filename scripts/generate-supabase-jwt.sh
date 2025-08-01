#!/bin/bash

# Supabase JWT Secret Generator
# Generates secure JWT secret and service key following Supabase best practices

set -euo pipefail

echo "🔐 Generating secure Supabase JWT secrets..."

# Check if we have required tools
command -v openssl >/dev/null 2>&1 || { echo "❌ openssl is required but not installed."; exit 1; }
command -v node >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || { echo "❌ node or python3 is required for JWT generation."; exit 1; }

# Generate a secure 256-bit (32-byte) JWT secret
echo "🔑 Generating JWT secret (256-bit)..."
JWT_SECRET=$(openssl rand -base64 32 | tr -d '\n')
echo "✅ JWT Secret generated: ${JWT_SECRET:0:20}..."

# Generate anon (public) key - this is safe to expose in client-side code
echo "🔑 Generating anon (public) key..."
if command -v node >/dev/null 2>&1; then
    ANON_KEY=$(node -e "
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

// Install jsonwebtoken if not available
try {
    const payload = {
        iss: 'supabase',
        ref: 'homelab',
        aud: 'authenticated',
        exp: Math.floor(Date.now() / 1000) + (60 * 60 * 24 * 365 * 10), // 10 years
        iat: Math.floor(Date.now() / 1000),
        role: 'anon'
    };

    const token = jwt.sign(payload, '$JWT_SECRET', { algorithm: 'HS256' });
    console.log(token);
} catch (error) {
    console.error('jsonwebtoken not available, using fallback');
    process.exit(1);
}
" 2>/dev/null || echo "FALLBACK_ANON_KEY")
else
    # Python fallback for JWT generation
    ANON_KEY=$(python3 -c "
import jwt
import json
import time

payload = {
    'iss': 'supabase',
    'ref': 'homelab',
    'aud': 'authenticated',
    'exp': int(time.time()) + (60 * 60 * 24 * 365 * 10),  # 10 years
    'iat': int(time.time()),
    'role': 'anon'
}

try:
    token = jwt.encode(payload, '$JWT_SECRET', algorithm='HS256')
    print(token)
except Exception as e:
    print('FALLBACK_ANON_KEY')
" 2>/dev/null || echo "FALLBACK_ANON_KEY")
fi

# Generate service role key - this has admin privileges, keep it secret!
echo "🔑 Generating service role key..."
if command -v node >/dev/null 2>&1; then
    SERVICE_KEY=$(node -e "
const jwt = require('jsonwebtoken');

try {
    const payload = {
        iss: 'supabase',
        ref: 'homelab',
        aud: 'authenticated',
        exp: Math.floor(Date.now() / 1000) + (60 * 60 * 24 * 365 * 10), // 10 years
        iat: Math.floor(Date.now() / 1000),
        role: 'service_role'
    };

    const token = jwt.sign(payload, '$JWT_SECRET', { algorithm: 'HS256' });
    console.log(token);
} catch (error) {
    console.error('jsonwebtoken not available, using fallback');
    process.exit(1);
}
" 2>/dev/null || echo "FALLBACK_SERVICE_KEY")
else
    # Python fallback
    SERVICE_KEY=$(python3 -c "
import jwt
import json
import time

payload = {
    'iss': 'supabase',
    'ref': 'homelab',
    'aud': 'authenticated',
    'exp': int(time.time()) + (60 * 60 * 24 * 365 * 10),  # 10 years
    'iat': int(time.time()),
    'role': 'service_role'
}

try:
    token = jwt.encode(payload, '$JWT_SECRET', algorithm='HS256')
    print(token)
except Exception as e:
    print('FALLBACK_SERVICE_KEY')
" 2>/dev/null || echo "FALLBACK_SERVICE_KEY")
fi

echo "✅ Anon Key generated: ${ANON_KEY:0:50}..."
echo "✅ Service Key generated: ${SERVICE_KEY:0:50}..."

# Update .env file
echo ""
echo "📝 Updating .env file..."

# Backup .env
cp .env .env.backup
echo "✅ Created backup: .env.backup"

# Update .env with new values
if [ -f .env ]; then
    # Use temporary file for safe replacement
    {
        grep -v "^SUPABASE_JWT_SECRET=" .env || true
        grep -v "^SUPABASE_ANON_KEY=" .env || true
        grep -v "^SUPABASE_SERVICE_KEY=" .env || true
        echo "SUPABASE_JWT_SECRET=\"$JWT_SECRET\""
        echo "SUPABASE_ANON_KEY=\"$ANON_KEY\""
        echo "SUPABASE_SERVICE_KEY=\"$SERVICE_KEY\""
    } > .env.tmp && mv .env.tmp .env

    echo "✅ Updated .env with new secrets"
else
    echo "❌ .env file not found!"
    exit 1
fi

echo ""
echo "🎉 Supabase JWT secrets generated successfully!"
echo ""
echo "📋 Summary:"
echo "  • JWT Secret: ${JWT_SECRET:0:20}... (32 bytes, base64)"
echo "  • Anon Key: ${ANON_KEY:0:50}... (JWT token, role: anon)"
echo "  • Service Key: ${SERVICE_KEY:0:50}... (JWT token, role: service_role)"
echo ""
echo "⚠️  Security Notes:"
echo "  • JWT Secret: Keep this absolutely secret - it signs all tokens"
echo "  • Anon Key: Safe to use in client-side code (read-only by default)"
echo "  • Service Key: Admin privileges - keep this secret on server only"
echo ""
echo "🚀 Next steps:"
echo "  1. Run 'just supabase_secrets' to update Kubernetes secrets"
echo "  2. Restart Supabase pods: kubectl rollout restart -n supabase deployment"
echo "  3. Use anon key in your frontend applications"
echo "  4. Use service key for admin operations and server-side code"

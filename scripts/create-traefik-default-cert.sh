#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=${1:-traefik-system}
SECRET_NAME=${2:-traefik-default-cert}
TMP_DIR=$(mktemp -d)
CRT="$TMP_DIR/tls.crt"
KEY="$TMP_DIR/tls.key"
CONF="$TMP_DIR/openssl.cnf"

cat > "$CONF" <<'EOF'
[req]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_ca
prompt             = no

[req_distinguished_name]
C  = US
ST = Local
L  = Local
O  = Homelab
OU = Traefik
CN = default.local

[req_ext]
subjectAltName = @alt_names

[v3_ca]
subjectAltName = @alt_names
basicConstraints = CA:false
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = localhost
DNS.2 = traefik.127.0.0.1.nip.io
DNS.3 = dashboard.127.0.0.1.nip.io
DNS.4 = vault.127.0.0.1.nip.io
DNS.5 = supabase.127.0.0.1.nip.io
DNS.6 = api.supabase.127.0.0.1.nip.io
DNS.7 = auth.supabase.127.0.0.1.nip.io
DNS.8 = storage.supabase.127.0.0.1.nip.io
DNS.9 = realtime.supabase.127.0.0.1.nip.io
DNS.10 = meta.supabase.127.0.0.1.nip.io
DNS.11 = *.127.0.0.1.nip.io
IP.1 = 127.0.0.1
EOF

# Generate self-signed cert valid for ~2 years
openssl req -x509 -nodes -newkey rsa:2048 -days 825 \
  -keyout "$KEY" -out "$CRT" -config "$CONF"

# Create or replace TLS secret
kubectl -n "$NAMESPACE" delete secret "$SECRET_NAME" --ignore-not-found
kubectl -n "$NAMESPACE" create secret tls "$SECRET_NAME" \
  --cert="$CRT" --key="$KEY"

echo "✅ Created TLS secret $SECRET_NAME in namespace $NAMESPACE"

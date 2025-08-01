#!/usr/bin/env node

// Supabase JWT Secret Generator
// Generates secure JWT secret and service key following Supabase best practices

const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const fs = require('fs');

console.log('🔐 Generating secure Supabase JWT secrets...');

// Generate a secure 256-bit (32-byte) JWT secret
console.log('🔑 Generating JWT secret (256-bit)...');
const jwtSecret = crypto.randomBytes(32).toString('base64');
console.log(`✅ JWT Secret generated: ${jwtSecret.substring(0, 20)}...`);

// Generate anon (public) key - this is safe to expose in client-side code
console.log('🔑 Generating anon (public) key...');
const anonPayload = {
    iss: 'supabase',
    ref: 'homelab',
    aud: 'authenticated',
    exp: Math.floor(Date.now() / 1000) + (60 * 60 * 24 * 365 * 10), // 10 years
    iat: Math.floor(Date.now() / 1000),
    role: 'anon'
};

const anonKey = jwt.sign(anonPayload, jwtSecret, { algorithm: 'HS256' });
console.log(`✅ Anon Key generated: ${anonKey.substring(0, 50)}...`);

// Generate service role key - this has admin privileges, keep it secret!
console.log('🔑 Generating service role key...');
const servicePayload = {
    iss: 'supabase',
    ref: 'homelab',
    aud: 'authenticated',
    exp: Math.floor(Date.now() / 1000) + (60 * 60 * 24 * 365 * 10), // 10 years
    iat: Math.floor(Date.now() / 1000),
    role: 'service_role'
};

const serviceKey = jwt.sign(servicePayload, jwtSecret, { algorithm: 'HS256' });
console.log(`✅ Service Key generated: ${serviceKey.substring(0, 50)}...`);

// Update .env file
console.log('');
console.log('📝 Updating .env file...');

if (!fs.existsSync('.env')) {
    console.error('❌ .env file not found!');
    process.exit(1);
}

// Backup .env
fs.copyFileSync('.env', '.env.backup');
console.log('✅ Created backup: .env.backup');

// Read existing .env content
const envContent = fs.readFileSync('.env', 'utf8');
const envLines = envContent.split('\n');

// Remove existing Supabase JWT lines and add new ones
const newLines = envLines.filter(line =>
    !line.startsWith('SUPABASE_JWT_SECRET=') &&
    !line.startsWith('SUPABASE_ANON_KEY=') &&
    !line.startsWith('SUPABASE_SERVICE_KEY=')
);

// Add new secrets
newLines.push(`SUPABASE_JWT_SECRET="${jwtSecret}"`);
newLines.push(`SUPABASE_ANON_KEY="${anonKey}"`);
newLines.push(`SUPABASE_SERVICE_KEY="${serviceKey}"`);

// Write updated .env
fs.writeFileSync('.env', newLines.join('\n'));
console.log('✅ Updated .env with new secrets');

console.log('');
console.log('🎉 Supabase JWT secrets generated successfully!');
console.log('');
console.log('📋 Summary:');
console.log(`  • JWT Secret: ${jwtSecret.substring(0, 20)}... (32 bytes, base64)`);
console.log(`  • Anon Key: ${anonKey.substring(0, 50)}... (JWT token, role: anon)`);
console.log(`  • Service Key: ${serviceKey.substring(0, 50)}... (JWT token, role: service_role)`);
console.log('');
console.log('⚠️  Security Notes:');
console.log('  • JWT Secret: Keep this absolutely secret - it signs all tokens');
console.log('  • Anon Key: Safe to use in client-side code (read-only by default)');
console.log('  • Service Key: Admin privileges - keep this secret on server only');
console.log('');
console.log('🚀 Next steps:');
console.log('  1. Run "just supabase_secrets" to update Kubernetes secrets');
console.log('  2. Restart Supabase pods: kubectl rollout restart -n supabase deployment');
console.log('  3. Use anon key in your frontend applications');
console.log('  4. Use service key for admin operations and server-side code');

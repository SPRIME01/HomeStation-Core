# Traefik Configuration Fixes

## Issue 1: ACME Certificate Email Domain

### Current Problem:
```yaml
--certificatesresolvers.letsencrypt.acme.email=admin@homestation.local
```
- `.local` domains are not valid for Let's Encrypt
- Causing all certificate requests to fail

### Solution Options:

#### Option A: Use Real Email (Recommended for Production)
```yaml
--certificatesresolvers.letsencrypt.acme.email=your-real-email@gmail.com
```

#### Option B: Disable ACME for Local Development
```yaml
# Remove ACME resolver entirely and use self-signed certificates
# This is better for local development where certificates aren't critical
```

#### Option C: Use Staging Environment
```yaml
--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
--certificatesresolvers.letsencrypt.acme.email=test@example.com
```

## Issue 2: Local Domain Strategy

### Current State:
- Using `.local` domains that can't get real certificates
- NodePort access only (no proper LoadBalancer)

### Recommended Approach:
```yaml
# For development, use either:
# 1. Self-signed certificates with local domains
# 2. Plain HTTP without TLS for local development
# 3. Use a real domain with DNS pointing to localhost/cluster IP
```

## Issue 3: LoadBalancer Configuration

### Install MetalLB for proper LoadBalancer support:
```yaml
# Add to ArgoCD apps
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metallb
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://metallb.github.io/metallb
    chart: metallb
    targetRevision: "0.13.12"
  destination:
    server: https://kubernetes.default.svc
    namespace: metallb-system
```

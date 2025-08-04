# Alternative Access Strategy for Rancher Desktop + WSL2
# 
# Root Cause: MetalLB LoadBalancer IPs are assigned within k3s cluster running in WSL2,
# but are not bridged to Windows host network, making them inaccessible from browser.
#
# Solution: Use NodePort + Host IP instead of LoadBalancer IPs

# ═══════════════════════════════════════════════════════════════
# WORKING ACCESS METHODS (Rancher Desktop WSL2)
# ═══════════════════════════════════════════════════════════════

## 1. Traefik Dashboard Access
# The k3s built-in Traefik has NodePorts:
# - HTTP: 32096 (port 80 maps to NodePort 32096)
# - HTTPS: 31239 (port 443 maps to NodePort 31239)
# - Dashboard: Need to enable via Traefik config

## 2. Service Discovery
# k3s node internal IP: 192.168.127.2 (not accessible from Windows)
# WSL2 IP: 172.19.138.186 (accessible from Windows)
# Windows Host IP: 192.168.0.50 (accessible externally)

## 3. Port Mapping Strategy
# Windows Host -> WSL2 -> k3s Node -> Pod
# Access via: localhost:nodeport or WSL2-IP:nodeport

## 4. Rancher Desktop Port Forwarding
# Rancher Desktop automatically forwards certain ports to localhost
# Need to check what's automatically forwarded vs manual port-forward needed

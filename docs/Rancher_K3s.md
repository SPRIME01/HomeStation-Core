# 🧾 Rancher Desktop + WSL2 Setup Documentation

## 📦 Overview

This setup uses **Rancher Desktop** on Windows with **WSL2 integration** to run a local Kubernetes cluster (K3s) and container runtime. It exposes the Kubernetes config and Docker socket to WSL2 distros for seamless development and automation.

---

## 🛠️ Installation Steps

### 1. Install Rancher Desktop
- Download from [rancherdesktop.io](https://rancherdesktop.io)
- Install with default settings

### 2. Factory Reset (Optional)
If needed:
- Go to **Preferences → Troubleshooting → Factory Reset**
- Wait for Rancher Desktop to restart or launch it manually

```powershell
Start-Process "C:\Program Files\Rancher Desktop\Rancher Desktop.exe"
```

---

## ⚙️ Configuration

### ✅ Container Runtime
- Go to **Preferences → Container Runtime**
- Select: `containerd` (recommended)
- Enable: **“Use Docker CLI with containerd (nerdctl)”**

### ✅ Kubernetes Settings
- Go to **Preferences → Kubernetes Settings**
- Enable Kubernetes
- Choose desired version (latest stable recommended)
- Wait for initialization

### ✅ WSL Integration
- Go to **Preferences → WSL Integration**
- ✅ Check **Expose Kubernetes config and Docker socket to WSL**
- Select your WSL2 distros (e.g., `Ubuntu`)

---

## 🔗 Kubeconfig Symlink (Optional)

If Rancher Desktop fails to convert your kubeconfig:

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.rd-kubeconfig" `
  -Target "$env:USERPROFILE\.kube\config"
```

---

## 🧪 Verification

### Kubernetes
```bash
kubectl config get-contexts
kubectl get nodes
```

### Docker / Nerdctl
```bash
docker version
docker run hello-world
# or
nerdctl run hello-world
```

---

## 🧼 Optional: Remove Docker Desktop

If Rancher Desktop meets all your needs:

- Uninstall Docker Desktop via Control Panel
- Clean up leftover files:
  ```powershell
  Remove-Item "$env:USERPROFILE\.docker" -Recurse -Force
  ```

---

## 🧠 Notes & Tips

- Rancher Desktop uses its own WSL2 distro (`rancher-desktop`)
- Kubernetes config is stored in:
  `C:\Users\<YourUsername>\AppData\Local\rancher-desktop\kubernetes\`
- Kubeconfig path:
  `~/.kube/config`
- You can run containers and Kubernetes workloads directly from WSL2

---

## 🔧 Future Modifications

Use this section to track any changes or enhancements made to the setup.

### Example Entries:
- **2025-08-01**: Switched container runtime from `containerd` to `dockerd` for compatibility with legacy scripts.
- **2025-08-15**: Added Pulumi and Ansible integration inside WSL2 for infrastructure automation.
- **2025-08-20**: Enabled SSH agent forwarding for secure access to GitHub from WSL2.

---

## 🪛 Troubleshooting Logs

Document issues and resolutions here for future reference.

### Example Entries:
- **Issue**: `kubectl get nodes` returns `connection refused`
  - **Resolution**: Kubernetes was not fully initialized. Restarted Rancher Desktop and verified kubeconfig path.

- **Issue**: Docker CLI not working in WSL2
  - **Resolution**: Enabled “Expose Docker socket to WSL” in Rancher Desktop settings.

- **Issue**: TLS certificate error when accessing K3s API
  - **Resolution**: Regenerated kubeconfig and restarted Rancher Desktop.

---

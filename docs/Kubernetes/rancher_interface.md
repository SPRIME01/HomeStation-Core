# 🧭 Rancher Desktop Settings: Workflow Impact and Reference Guide

This document helps you understand how Rancher Desktop settings affect your workflow and system performance, and provides a complete reference of all configurable options.

---

## 📘 Companion Guide: How Settings Affect Workflow and Performance

### 🐳 Container Runtime

**Options:**
- `containerd`: Lightweight, native to K3s
- `dockerd (moby)`: Docker-compatible, useful for legacy tooling

**Impact:**
- `containerd` is faster and more efficient for Kubernetes workloads.
- `dockerd` enables compatibility with Docker CLI and Docker Compose.
- Switching runtimes may affect how images are built and stored.

---

### 📦 Kubernetes Settings

**Options:**
- Enable/Disable Kubernetes
- Select Kubernetes version
- View `kubeconfig` path

**Impact:**
- Disabling Kubernetes reduces resource usage if you're only using containers.
- Choosing a newer version gives access to updated APIs and features.
- The `kubeconfig` path is critical for CLI tools like `kubectl`, `helm`, and CI/CD pipelines.

---

### 🧮 Virtual Machine Settings

**Options:**
- CPU cores
- Memory allocation
- Disk size

**Impact:**
- More CPU/memory improves pod startup time and container performance.
- Over-provisioning may slow down your host system.
- Disk size affects how many images and volumes you can store.

---

### 🧰 WSL Integration

**Options:**
- Expose Docker socket to WSL
- Expose Kubernetes config to WSL

**Impact:**
- Enables seamless CLI access from Linux distros.
- Essential for scripting, automation, and using tools like `kubectl` inside WSL.
- Improves developer experience for hybrid Windows/Linux workflows.

---

### 📊 Logs and Diagnostics

**Options:**
- View logs by service
- Export logs

**Impact:**
- Helps troubleshoot pod failures, startup issues, and runtime errors.
- Useful for debugging provisioning scripts or container crashes.

---

### 🧭 System Tray Menu

**Options:**
- Start/Stop Kubernetes
- Open Preferences
- View Logs
- Quit Rancher Desktop

**Impact:**
- Quick access to core functions without opening the full UI.
- Ideal for managing Rancher Desktop during multitasking or scripting.

---

## 📑 Reference: Rancher Desktop Settings and Toggles

| **Setting**                        | **Location**               | **Description**                                                                 | **Default**         |
|-----------------------------------|----------------------------|---------------------------------------------------------------------------------|---------------------|
| Container Runtime                 | Preferences > Runtime      | Choose between `containerd` and `dockerd (moby)`                               | `containerd`        |
| Kubernetes Enabled                | Preferences > Kubernetes   | Toggle Kubernetes on/off                                                       | Enabled             |
| Kubernetes Version                | Preferences > Kubernetes   | Select version of K3s to run                                                   | Latest stable       |
| Kubeconfig Path                   | Preferences > Kubernetes   | Shows path to `kubeconfig` file                                                | `C:\Users\<User>\.kube\config` |
| CPU Allocation                    | Preferences > VM           | Number of CPU cores allocated to Rancher Desktop                               | 2 cores             |
| Memory Allocation                 | Preferences > VM           | Amount of RAM allocated                                                        | 4 GB                |
| Disk Size                         | Preferences > VM           | Storage space for container images and volumes                                 | 20 GB               |
| Expose Docker Socket to WSL       | Preferences > WSL Integration | Makes Docker socket available in WSL2 distros                              | Enabled             |
| Expose Kubernetes Config to WSL   | Preferences > WSL Integration | Makes `kubeconfig` available in WSL2 distros                              | Enabled             |
| View Logs                         | Logs Tab                   | Displays logs for Kubernetes, container runtime, and system                    | N/A                 |
| Start/Stop Kubernetes             | System Tray Menu           | Starts or stops the K3s cluster                                                | N/A                 |
| Quit Rancher Desktop              | System Tray Menu           | Exits the application                                                          | N/A                 |

---

## ✅ Summary

Understanding Rancher Desktop’s settings empowers you to:

- Optimize performance for your local Kubernetes cluster
- Streamline container workflows across Windows and WSL2
- Troubleshoot issues with confidence
- Customize your environment for scripting, automation, and development

# Homelab Bootstrap

One‑command bootstrap for the Rancher‑Desktop‑backed K3s homelab.

```bash
just init            # install deps & git hooks
just provision core  # deploy Argo CD + core stack
just validate        # run lint + unit tests + health‑checks
```

For new micro‑services:

```bash
just generate service name=my‑api
just generate argo-app name=my‑api src=apps/my-api
just deploy
```

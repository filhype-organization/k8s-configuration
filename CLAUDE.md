# CLAUDE.md — k8s-configuration

## Contexte

Repo de configuration du cluster Kubernetes bare-metal (HP Elite 802 + 2 Jetson Nano).
Contient la configuration GitOps Flux et les manifestes d'infrastructure.

## Infrastructure

| Élément            | Détail                                    |
|--------------------|-------------------------------------------|
| Control-plane      | HP Elite 802 — Core i7, 16 Go — x86_64   |
| Workers            | 2× Jetson Nano — ARM64                    |
| OS                 | Ubuntu Server 24.04 LTS (hp) / 22.04 LTS |
| IP control-plane   | 192.168.1.23 (fixe)                       |
| Runtime            | containerd                                |
| CNI                | Flannel (multi-arch)                      |
| K8s                | 1.32.x                                    |

## Contrainte multi-arch

Les workers Jetson Nano (ARM64) ne peuvent exécuter que des images ARM64.
Tout déploiement non-ARM64 doit inclure `nodeSelector: kubernetes.io/arch: amd64`.

## Structure du repo

```
flux/         → Ressources FluxCD (appliquer avec kubectl apply -k flux/)
infra/        → Manifestes Kustomize : metallb, metallb-config, traefik, cloudflared
cluster-k8s/  → Documentation d'installation pas à pas
docs/         → Documentation opérationnelle (infra-stack.md)
```

## Repos liés

| Repo                       | Rôle                                    |
|----------------------------|-----------------------------------------|
| `iac-chucknorris-backend`  | Manifestes K8s du backend (deploy/)     |
| `k8s-configuration` (ce repo) | Infra cluster + bootstrap Flux       |

## Conventions

- Documentation en français
- Fichiers de doc préfixés par numéro pour ordonner les étapes (ex: `01-`, `02-`)
- Commandes testées pour Ubuntu 24.04 + containerd + systemd cgroups

# k8s-configuration — Cluster Kubernetes HP Elite 802

Cluster bare-metal 3 nœuds (1 control-plane x86_64 + 2 workers ARM64 Jetson Nano).

Ce repo contient :
- La configuration GitOps Flux (GitRepositories + Kustomizations)
- Les manifestes d'infrastructure (MetalLB, Traefik, Cloudflared)
- La documentation d'installation et d'exploitation du cluster

## Stack

| Composant    | Technologie                              |
|--------------|------------------------------------------|
| OS           | Ubuntu Server 24.04 LTS (hp) / 22.04 LTS (Jetsons) |
| Runtime      | containerd                               |
| CNI          | Flannel (multi-arch x86_64 + ARM64)      |
| K8s          | 1.32.x                                   |
| GitOps       | FluxCD v2                                |
| Load Balancer| MetalLB (L2 mode)                        |
| Ingress      | Traefik v3                               |
| Tunnel       | Cloudflared                              |
| Secrets      | Sealed Secrets (Bitnami)                 |

## Nœuds

| Nom             | Rôle          | Archi   | IP            | Statut |
|-----------------|---------------|---------|---------------|--------|
| hp              | control-plane | x86_64  | 192.168.1.23  | Ready  |
| leeson-desktop  | worker        | ARM64   | 192.168.1.26  | Ready  |
| leeson-jetson2  | worker        | ARM64   | 192.168.1.25  | Ready  |

## Structure

```
k8s-configuration/
├── cluster-k8s/          # Guide d'installation pas à pas
│   ├── 01-prerequisites.md
│   ├── 02-containerd.md
│   ├── 03-kubeadm-install.md
│   ├── 04-cluster-init.md
│   ├── 05-flannel.md
│   ├── 06-post-install.md
│   ├── 07-troubleshooting.md
│   └── 08-argocd.md
├── infra/                # Manifestes Kustomize des composants infra
│   ├── metallb/
│   ├── metallb-config/
│   ├── traefik/
│   └── cloudflared/
├── flux/                 # Ressources FluxCD (GitRepositories + Kustomizations)
│   ├── kustomization.yaml            # Bootstrap : kubectl apply -k flux/
│   ├── gitrepository-k8s-config.yaml
│   ├── gitrepository-backend.yaml
│   ├── infra-metallb.yaml
│   ├── infra-metallb-config.yaml
│   ├── infra-traefik.yaml
│   ├── infra-cloudflared.yaml
│   └── chuck-norris-backend.yaml
└── docs/
    └── infra-stack.md    # Stack infra, bootstrap Flux, commandes utiles
```

## Installation du cluster

1. [Prérequis système](cluster-k8s/01-prerequisites.md)
2. [Installation de containerd](cluster-k8s/02-containerd.md)
3. [Installation de kubeadm / kubelet / kubectl](cluster-k8s/03-kubeadm-install.md)
4. [Initialisation du cluster](cluster-k8s/04-cluster-init.md)
5. [Installation du CNI Flannel](cluster-k8s/05-flannel.md)
6. [Post-install et vérifications](cluster-k8s/06-post-install.md)
7. [Dépannage](cluster-k8s/07-troubleshooting.md)
8. [ArgoCD via OLM](cluster-k8s/08-argocd.md)

## Bootstrap Flux

Après installation du cluster, appliquer les ressources Flux :

```bash
kubectl apply -k flux/
```

Voir [docs/infra-stack.md](docs/infra-stack.md) pour le détail et les commandes de vérification.

# Cluster Kubernetes — HP Elite 802

Cluster bare metal 3 nœuds (1 control-plane x86_64 + 2 workers ARM64 Jetson Nano).

## Stack

- **OS** : Ubuntu Server 24.04 LTS (hp) / 22.04 LTS (Jetsons)
- **Runtime** : containerd
- **CNI** : Flannel (multi-arch x86_64 + ARM64)
- **K8s** : 1.32.x (dernière stable)
- **OLM** : Operator Lifecycle Manager (community operators)
- **GitOps** : ArgoCD v3.x via OLM

## Étapes d'installation

1. [Prérequis système](docs/01-prerequisites.md)
2. [Installation de containerd](docs/02-containerd.md)
3. [Installation de kubeadm / kubelet / kubectl](docs/03-kubeadm-install.md)
4. [Initialisation du cluster](docs/04-cluster-init.md)
5. [Installation du CNI Flannel](docs/05-flannel.md)
6. [Post-install et vérifications](docs/06-post-install.md)
7. [Dépannage](docs/07-troubleshooting.md)
8. [ArgoCD via OLM](docs/08-argocd.md)

## Noeuds

| Nom             | Rôle          | Archi   | IP            | Statut      |
|-----------------|---------------|---------|---------------|-------------|
| hp              | control-plane | x86_64  | 192.168.1.23  | Ready       |
| leeson-desktop  | worker        | ARM64   | 192.168.1.26  | Ready       |
| leeson-jetson2  | worker        | ARM64   | 192.168.1.25  | Ready       |

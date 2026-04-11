# Cluster Kubernetes — HP Elite 802

Cluster K8s single-node sur bare metal, extensible avec des Jetson Nano (ARM64).

## Stack

- **OS** : Ubuntu Server 24.04 LTS
- **Runtime** : containerd
- **CNI** : Flannel (multi-arch x86_64 + ARM64)
- **K8s** : 1.32.x (dernière stable)

## Étapes d'installation

1. [Prérequis système](docs/01-prerequisites.md)
2. [Installation de containerd](docs/02-containerd.md)
3. [Installation de kubeadm / kubelet / kubectl](docs/03-kubeadm-install.md)
4. [Initialisation du cluster](docs/04-cluster-init.md)
5. [Installation du CNI Flannel](docs/05-flannel.md)
6. [Post-install et vérifications](docs/06-post-install.md)
7. [Dépannage](docs/07-troubleshooting.md)

## Noeuds

| Nom     | Rôle             | Archi   | Statut     |
|---------|------------------|---------|------------|
| hp-k8s  | control-plane    | x86_64  | prévu      |
| jetson1 | worker           | ARM64   | futur      |
| jetson2 | worker           | ARM64   | futur      |

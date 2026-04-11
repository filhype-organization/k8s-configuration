# CLAUDE.md — k8s Infrastructure

## Contexte du projet

Cluster Kubernetes single-node (pour l'instant) hébergé sur un HP Elite 802 physique.
Usage : projets de dev perso + Home Assistant.

## Infrastructure

| Élément       | Détail                                      |
|---------------|---------------------------------------------|
| Noeud actuel  | HP Elite 802 — Core i7, 16 Go RAM           |
| OS            | Ubuntu Server 24.04 LTS (à jour)            |
| Architecture  | x86_64                                      |
| IP            | 192.168.1.23 (fixe locale)                  |
| Runtime       | containerd                                  |
| CNI           | Flannel (multi-arch ready)                  |
| K8s           | Dernière version stable (1.32.x)            |

## Noeuds futurs prévus

Deux Jetson Nano (ARM64) à ajouter comme worker nodes.
→ Toute configuration CNI/réseau doit rester compatible ARM64.

## Conventions

- La doc est en français
- Chaque fichier de doc est préfixé par un numéro (ex: `01-`, `02-`) pour ordonner les étapes
- Les commandes sont testées pour Ubuntu 24.04 + containerd + systemd cgroups
- Le scheduling est activé sur le control-plane (noeud unique)

## Structure du répertoire

```
k8s/
├── CLAUDE.md          # Ce fichier
├── README.md          # Vue d'ensemble et liens
├── doc/
│   └── docs/
│       ├── 01-prerequisites.md
│       ├── 02-containerd.md
│       ├── 03-kubeadm-install.md
│       ├── 04-cluster-init.md
│       ├── 05-flannel.md
│       ├── 06-post-install.md
│       ├── 07-troubleshooting.md
│       └── 08-argocd.md      # ArgoCD via OLM
└── argocd/
    ├── 00-namespace.yaml      # Namespace argocd
    ├── 01-subscription.yaml   # Subscription OLM (argocd-operator)
    └── 02-argocd-instance.yaml # CR ArgoCD (v1beta1)
```

## Contrainte multi-arch

Les workers Jetson Nano (ARM64) ne peuvent pas exécuter les images
`argocd-operator` ni ArgoCD (amd64 uniquement). Tout déploiement applicatif
non-ARM64 doit inclure un `nodeSelector: kubernetes.io/arch: amd64`.

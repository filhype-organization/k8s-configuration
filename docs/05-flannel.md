# 05 — Installation du CNI Flannel

Flannel est choisi pour sa simplicité et son support natif multi-arch (x86_64 + ARM64),
ce qui permettra d'ajouter les Jetson Nano sans configuration supplémentaire.

## 1. Appliquer le manifeste Flannel

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

## 2. Vérifier que les pods Flannel démarrent

```bash
kubectl get pods -n kube-flannel
# Attendre que le pod flannel passe en Running (peut prendre 1-2 minutes)
```

## 3. Vérifier que le noeud passe en Ready

```bash
kubectl get nodes
# Le noeud doit afficher Ready
```

## Notes pour l'ajout des Jetson Nano

Flannel supporte ARM64 nativement via ses images multi-arch officielles.
Aucune configuration CNI supplémentaire ne sera nécessaire lors de l'ajout des workers Jetson.
Le pod `kube-flannel` se déploiera automatiquement sur chaque nouveau noeud (DaemonSet).

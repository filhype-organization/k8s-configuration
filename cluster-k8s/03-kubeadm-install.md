# 03 — Installation de kubeadm, kubelet et kubectl

## 1. Ajouter le dépôt Kubernetes

```bash
# Créer le répertoire pour les clés GPG si nécessaire
sudo mkdir -p /etc/apt/keyrings

# Télécharger la clé GPG du dépôt Kubernetes 1.32
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Ajouter le dépôt
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
```

## 2. Installer les paquets

```bash
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
```

## 3. Épingler les versions (éviter une mise à jour accidentelle)

```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

## 4. Vérifier les versions installées

```bash
kubeadm version
kubectl version --client
kubelet --version
```

## 5. Activer kubelet

```bash
sudo systemctl enable kubelet
```

> kubelet ne démarrera pas correctement avant l'init du cluster — c'est normal.

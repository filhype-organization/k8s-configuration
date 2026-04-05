# 01 — Prérequis système

À effectuer sur le noeud control-plane (HP Elite 802).

## 1. Désactiver le swap

Kubernetes exige que le swap soit désactivé.

```bash
sudo swapoff -a
# Rendre permanent : commenter la ligne swap dans /etc/fstab
sudo sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab
```

Vérification :
```bash
free -h  # La ligne Swap doit afficher 0
```

## 2. Charger les modules noyau requis

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

## 3. Configurer les paramètres sysctl

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

Vérification :
```bash
sysctl net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward
# Doit afficher 1 pour chaque paramètre
```

## 4. Vérifier que l'IP fixe est bien configurée

```bash
ip addr show
# Repérer l'interface principale (ex: eno1, eth0) et son IP fixe
```

## 5. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gpg
```

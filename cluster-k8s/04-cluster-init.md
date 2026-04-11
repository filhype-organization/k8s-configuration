# 04 — Initialisation du cluster

## 1. Initialiser le cluster avec kubeadm

Le CIDR `10.244.0.0/16` est requis par Flannel.
IP fixe du serveur : `192.168.1.23`.

```bash
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=192.168.1.23
```

> L'initialisation prend quelques minutes. À la fin, kubeadm affiche une commande `kubeadm join` — **la noter précieusement** pour ajouter les Jetson Nano plus tard.

## 2. Configurer kubectl pour l'utilisateur courant

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## 3. Vérifier l'état du cluster

```bash
kubectl get nodes
# STATUS = NotReady à ce stade : c'est NORMAL, le CNI n'est pas encore installé
# Passer à l'étape 05 pour installer Flannel

kubectl get pods -n kube-system
# coredns sera Pending jusqu'à l'installation du CNI : c'est NORMAL
```

> Ne pas s'arrêter ici — continuer directement vers `05-flannel.md`.

## Commande join pour les futurs noeuds

> **Cette commande est réservée aux workers (Jetson Nano). Ne pas l'exécuter sur le control-plane.**

À exécuter sur chaque nouveau noeud worker :

```bash
sudo kubeadm join 192.168.1.23:6443 --token dfk4rb.d2f8anff623dz6gr \
        --discovery-token-ca-cert-hash sha256:07537dcbf514287b2aa56d6e2cf7e075f5630286d3affa92553a3ae67ef932d4
```

> **Attention** : ce token est valable 24h. S'il a expiré, en générer un nouveau depuis le control-plane :
> ```bash
> kubeadm token create --print-join-command
> ```

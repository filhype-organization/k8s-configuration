# 06 — Post-install et vérifications

## 1. Autoriser le scheduling sur le control-plane

En cluster single-node, il faut retirer le taint qui empêche les pods applicatifs
de se déployer sur le noeud control-plane.

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

Vérification :
```bash
kubectl describe node | grep -i taint
# Ne doit plus afficher de taint NoSchedule
```

## 2. Vérification globale du cluster

```bash
# État des noeuds
kubectl get nodes -o wide

# Tous les pods système doivent être Running ou Completed
kubectl get pods -A

# Informations sur le cluster
kubectl cluster-info
```

## 3. Test de déploiement

Déployer un pod de test pour valider le cluster end-to-end :

```bash
kubectl run test-nginx --image=nginx --port=80
kubectl get pod test-nginx
# Attendre Running

# Nettoyer
kubectl delete pod test-nginx
```

## 4. Activer la complétion kubectl (optionnel)

```bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

## 5. Récupérer la commande join pour les futurs noeuds

```bash
kubeadm token create --print-join-command
```

Garder cette commande pour ajouter les Jetson Nano.

## Récapitulatif — État attendu après installation complète

```
$ kubectl get nodes
NAME      STATUS   ROLES           AGE   VERSION
hp-k8s   Ready    control-plane   Xm    v1.32.x

$ kubectl get pods -A
NAMESPACE      NAME                               READY   STATUS
kube-system    coredns-*                          1/1     Running
kube-system    etcd-hp-k8s                        1/1     Running
kube-system    kube-apiserver-hp-k8s              1/1     Running
kube-system    kube-controller-manager-hp-k8s     1/1     Running
kube-system    kube-proxy-*                       1/1     Running
kube-system    kube-scheduler-hp-k8s              1/1     Running
kube-flannel   kube-flannel-ds-*                  1/1     Running
```

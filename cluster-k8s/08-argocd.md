# 08 — ArgoCD via OLM

## Vue d'ensemble

ArgoCD est déployé via l'**Operator Lifecycle Manager (OLM)** en utilisant le
`argocd-operator` disponible dans le catalogue OperatorHub.io.

| Élément              | Détail                                     |
|----------------------|--------------------------------------------|
| Opérateur            | `argocd-operator` v0.17.0 (canal `alpha`)  |
| Instance ArgoCD      | v3.1.11                                    |
| Namespace opérateur  | `operators` (OperatorGroup global)         |
| Namespace instance   | `argocd`                                   |
| Accès UI             | NodePort HTTP :31519 / HTTPS :30403        |
| URL locale           | `http://192.168.1.23:31519`                |

---

## Architecture du déploiement

```
OLM (namespace: olm)
  └── CatalogSource: operatorhubio-catalog
        └── PackageManifest: argocd-operator

Namespace: operators
  ├── OperatorGroup: global-operators  (AllNamespaces — préexistant)
  ├── Subscription: argocd-operator
  │     └── InstallPlan → CSV: argocd-operator.v0.17.0
  └── Deployment: argocd-operator-controller-manager
        └── nodeSelector: kubernetes.io/arch=amd64

Namespace: argocd
  ├── ArgoCD CR: argocd
  ├── argocd-application-controller-0      (StatefulSet)
  ├── argocd-applicationset-controller     (Deployment)
  ├── argocd-redis                         (Deployment)
  ├── argocd-repo-server                   (Deployment)
  └── argocd-server                        (Deployment, NodePort)
```

---

## Fichiers de configuration

```
k8s/argocd/
├── 00-namespace.yaml          # Namespace "argocd"
├── 01-subscription.yaml       # Subscription OLM + nodeSelector amd64
└── 02-argocd-instance.yaml    # CR ArgoCD (v1beta1)
```

### Ordre d'application

```bash
kubectl apply -f argocd/00-namespace.yaml
kubectl apply -f argocd/01-subscription.yaml
# Attendre que le CSV soit Succeeded (~1-2 min)
kubectl get csv argocd-operator.v0.17.0 -n operators
kubectl apply -f argocd/02-argocd-instance.yaml
```

---

## Contrainte architecture (important)

Le cluster est **multi-arch** : nœud control-plane en `x86_64` (hp) et workers
en `ARM64` (Jetson Nano). Les images `argocd-operator` et ArgoCD v3.x ne sont
**pas disponibles pour ARM64**.

**Sans contrainte, les pods crashent avec `exec format error`.**

Deux `nodeSelector` sont donc définis :

1. **Sur la Subscription** (`spec.config.nodeSelector`) — propagé aux futures
   mises à jour de l'opérateur par OLM.
2. **Sur le Deployment de l'opérateur** (`kubectl patch`) — nécessaire car OLM
   ne rétro-propage pas `spec.config` sur un déploiement existant.
3. **Sur le CR ArgoCD** (`spec.nodePlacement.nodeSelector`) — tous les pods
   ArgoCD sont contraints sur `hp`.

```yaml
nodeSelector:
  kubernetes.io/arch: amd64
```

---

## Accès à l'interface web

```
URL : http://192.168.1.23:31519
Login : admin
```

### Récupérer le mot de passe initial

Le mot de passe initial est généré par l'opérateur et stocké dans le secret
`argocd-cluster` (différent du comportement standard ArgoCD qui utilise
`argocd-initial-admin-secret`) :

```bash
kubectl get secret argocd-cluster -n argocd \
  -o jsonpath='{.data.admin\.password}' | base64 --decode
```

> **Changer le mot de passe après la première connexion** via
> *User Info → Update Password* dans l'interface.

---

## Vérifications post-déploiement

```bash
# État global de l'instance
kubectl get argocd argocd -n argocd

# Tous les pods doivent être 1/1 Running sur le nœud "hp"
kubectl get pods -n argocd -o wide

# CSV de l'opérateur — doit être Succeeded
kubectl get csv argocd-operator.v0.17.0 -n operators

# Service NodePort
kubectl get svc argocd-server -n argocd
```

Résultat attendu :

```
NAME      AGE
argocd    ...

$ kubectl get pods -n argocd -o wide
NAME                                            READY   NODE
argocd-application-controller-0                1/1     hp
argocd-applicationset-controller-xxx           1/1     hp
argocd-redis-xxx                               1/1     hp
argocd-repo-server-xxx                         1/1     hp
argocd-server-xxx                              1/1     hp

$ kubectl get csv argocd-operator.v0.17.0 -n operators
NAME                      PHASE
argocd-operator.v0.17.0   Succeeded

$ kubectl get svc argocd-server -n argocd
NAME            TYPE       PORT(S)
argocd-server   NodePort   80:31519/TCP,443:30403/TCP
```

---

## Mise à jour de l'opérateur

OLM gère les mises à jour automatiquement (`installPlanApproval: Automatic`).
Pour passer en mise à jour manuelle, modifier la Subscription :

```yaml
installPlanApproval: Manual
```

Puis approuver manuellement :

```bash
kubectl get installplan -n operators
kubectl patch installplan <nom> -n operators \
  --type merge -p '{"spec":{"approved":true}}'
```

---

## Désinstallation

```bash
# 1. Supprimer l'instance ArgoCD
kubectl delete argocd argocd -n argocd

# 2. Supprimer la Subscription et le CSV
kubectl delete subscription argocd-operator -n operators
kubectl delete csv argocd-operator.v0.17.0 -n operators

# 3. Supprimer le namespace
kubectl delete namespace argocd

# 4. Supprimer les CRDs (optionnel — supprime toutes les données)
kubectl get crd | grep argoproj.io | awk '{print $1}' | xargs kubectl delete crd
```

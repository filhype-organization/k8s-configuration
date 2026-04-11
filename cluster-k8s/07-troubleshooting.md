# 07 — Dépannage

## Flannel : CrashLoopBackOff — `x509: certificate signed by unknown authority`

### Symptômes

```
Failed to create SubnetManager: error retrieving pod spec for 'kube-flannel/kube-flannel-ds-XXXXX':
Get "https://192.168.1.23:6443/...": tls: failed to verify certificate: x509: certificate signed by unknown authority
```

Le pod flannel du control-plane boucle en `CrashLoopBackOff` (typiquement 1000+ redémarrages).
Les pods flannel sur les workers peuvent rester fonctionnels.

### Diagnostic

```bash
kubectl logs <pod-flannel> -n kube-flannel --tail=20
kubectl describe pod <pod-flannel> -n kube-flannel
```

Vérifier les args du DaemonSet :

```bash
kubectl get daemonset kube-flannel-ds -n kube-flannel -o jsonpath='{.spec.template.spec.containers[0].args}'
```

### Cause racine

Le flag `--kube-api-url=<IP>:6443` a été ajouté manuellement au DaemonSet flannel.

Quand ce flag est présent, flannel utilise `clientcmd.BuildConfigFromFlags(url, "")` au lieu de
`rest.InClusterConfig()`. Dans certaines configurations, ce code path ne charge pas correctement
le CA cert du service account projeté (`/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`),
rendant la vérification TLS du serveur API impossible.

Le certificat du serveur API est pourtant valide — la vérification réussit quand le bon CA est utilisé :

```bash
kubectl get configmap kube-root-ca.crt -n kube-flannel -o jsonpath='{.data.ca\.crt}' > /tmp/ca.crt
openssl s_client -connect 192.168.1.23:6443 -CAfile /tmp/ca.crt </dev/null | grep -i verify
# Verification: OK
```

### Solution

Supprimer le flag `--kube-api-url` (et `--v=9` s'il est présent) du DaemonSet. Flannel
utilise l'in-cluster config par défaut et trouve le serveur API via la variable d'environnement
`KUBERNETES_SERVICE_HOST` injectée par Kubernetes.

```bash
# Identifier les index des args à supprimer
kubectl get daemonset kube-flannel-ds -n kube-flannel \
  -o jsonpath='{.spec.template.spec.containers[0].args}'

# Supprimer --kube-api-url et --v=9 (patch JSON, adapter les index selon l'ordre réel)
kubectl patch daemonset kube-flannel-ds -n kube-flannel --type=json \
  -p='[
    {"op":"remove","path":"/spec/template/spec/containers/0/args/2"},
    {"op":"remove","path":"/spec/template/spec/containers/0/args/2"}
  ]'

# Attendre le rollout
kubectl rollout status daemonset/kube-flannel-ds -n kube-flannel --timeout=60s
```

Vérifier que tous les pods flannel passent en `Running` :

```bash
kubectl get pods -n kube-flannel -o wide
```

### Effet de bord observé

Les pods CoreDNS en état `Unknown` sont revenus en `Running` après la correction de flannel,
confirmant que le réseau overlay était dégradé à cause du pod flannel défaillant sur le control-plane.

### Prévention

Ne pas ajouter `--kube-api-url` au DaemonSet flannel. La configuration standard sans ce flag
fonctionne pour les architectures x86_64 et ARM64 (Jetson Nano inclus).

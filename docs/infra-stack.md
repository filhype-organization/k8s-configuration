# Infrastructure Stack

## Stack technique

| Composant         | Technologie                        |
|-------------------|------------------------------------|
| GitOps            | FluxCD v2                          |
| Load Balancer     | MetalLB (mode L2)                  |
| Ingress           | Traefik v3 (HelmRelease)           |
| Tunnel            | Cloudflared                        |
| Secrets           | Sealed Secrets (Bitnami)           |

## Nœuds du cluster

| Hostname        | Rôle          | Archi   | IP            |
|-----------------|---------------|---------|---------------|
| hp              | control-plane | x86_64  | 192.168.1.23  |
| leeson-desktop  | worker        | ARM64   | 192.168.1.26  |
| leeson-jetson2  | worker        | ARM64   | 192.168.1.25  |

---

## MetalLB

MetalLB fournit un LoadBalancer logiciel en mode L2 pour le cluster bare-metal.

| Paramètre   | Valeur                          |
|-------------|---------------------------------|
| Namespace   | `metallb-system`                |
| Mode        | L2 Advertisement                |
| Pool IP     | `192.168.1.200 – 192.168.1.210` |

Le pool d'IPs doit être en dehors de la plage DHCP du routeur. L'IP assignée à Traefik sera l'adresse publique du cluster sur le réseau local.

Manifestes : `infra/metallb/`, `infra/metallb-config/`

## Traefik

Traefik est le contrôleur d'ingress déployé via Helm dans le namespace `ingress`.

| Paramètre    | Valeur                              |
|--------------|-------------------------------------|
| Namespace    | `ingress`                           |
| IngressClass | `traefik` (défaut)                  |
| Entrypoints  | `web` (80), `websecure` (443)       |
| Service type | `LoadBalancer` (IP assignée par MetalLB) |

Manifestes : `infra/traefik/`

## Cloudflared

Tunnel Cloudflare pour exposer le cluster sans ouvrir de port entrant.

Manifestes : `infra/cloudflared/`

---

## GitOps — Bootstrap Flux

### Architecture des Kustomizations

```
flux-system (Flux)
├── GitRepository: iac-k8s-configuration  → ce repo
│     ├── Kustomization: infra-metallb          → infra/metallb/
│     ├── Kustomization: infra-metallb-config   → infra/metallb-config/
│     ├── Kustomization: infra-traefik          → infra/traefik/
│     └── Kustomization: infra-cloudflared      → infra/cloudflared/
│
└── GitRepository: iac-chucknorris-backend → repo backend
      └── Kustomization: chuck-norris-backend   → deploy/
```

### Ordre de déploiement (dependsOn)

```
infra-metallb
    └→ infra-metallb-config   (CRDs MetalLB disponibles)
           └→ infra-traefik   (pool IP configuré)
                  └→ infra-cloudflared
                  └→ chuck-norris-backend
```

### Premier bootstrap (à appliquer une seule fois)

```bash
# Appliquer toutes les ressources Flux d'un coup
kubectl apply -k flux/

# Ou dans l'ordre explicite :
kubectl apply -f flux/gitrepository-k8s-config.yaml
kubectl apply -f flux/gitrepository-backend.yaml
kubectl apply -f flux/infra-metallb.yaml
kubectl apply -f flux/infra-metallb-config.yaml
kubectl apply -f flux/infra-traefik.yaml
kubectl apply -f flux/infra-cloudflared.yaml
kubectl apply -f flux/chuck-norris-backend.yaml
```

### Vérifier le statut

```bash
kubectl get gitrepository,kustomization -n flux-system
kubectl get helmrelease -A
kubectl get all -n metallb-system
kubectl get all -n ingress
```

### Forcer une réconciliation

```bash
# Réconcilier l'infra
kubectl annotate gitrepository iac-k8s-configuration -n flux-system \
  reconcile.fluxcd.io/requestedAt="$(date -u +%Y-%m-%dT%H:%M:%SZ)" --overwrite

# Réconcilier le backend
kubectl annotate gitrepository iac-chucknorris-backend -n flux-system \
  reconcile.fluxcd.io/requestedAt="$(date -u +%Y-%m-%dT%H:%M:%SZ)" --overwrite
```

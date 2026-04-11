# 02 — Installation et configuration de containerd

## 1. Installer containerd

```bash
sudo apt update
sudo apt install -y containerd
```

## 2. Générer la configuration par défaut

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

## 3. Activer le cgroup driver systemd

C'est obligatoire sur Ubuntu 24.04 (qui utilise systemd comme init system).

```bash
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
```

Vérification :
```bash
grep 'SystemdCgroup' /etc/containerd/config.toml
# Doit afficher : SystemdCgroup = true
```

## 4. Activer et démarrer containerd

```bash
sudo systemctl enable containerd
sudo systemctl restart containerd
sudo systemctl status containerd
```

## 5. Vérifier que containerd fonctionne

```bash
sudo ctr version
```

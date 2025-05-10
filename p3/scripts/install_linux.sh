#!/bin/bash

set -e

echo "[INFO] Updating packages and installing dependencies..."
sudo apt update -y
sudo apt install -y curl ca-certificates gnupg lsb-release

# Install kubectl
if ! command -v kubectl &> /dev/null; then
  echo "[INFO] Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

# Install k3d
if ! command -v k3d &> /dev/null; then
  echo "[INFO] Installing k3d..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# Install Argo CD CLI
if ! command -v argocd &> /dev/null; then
  echo "[INFO] Installing Argo CD CLI..."
  curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
  chmod +x argocd
  sudo mv argocd /usr/local/bin/
fi

# Create K3d cluster with port 8888 exposed
echo "[INFO] Creating K3d cluster..."
k3d cluster create iot-cluster --api-port 6550 -p "8888:80@loadbalancer" --wait

# Create namespaces
kubectl create namespace argocd || true
kubectl create namespace dev || true

# Install Argo CD
echo "[INFO] Installing Argo CD into Kubernetes..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[INFO] Waiting for Argo CD server to be ready..."
kubectl wait --for=condition=available --timeout=180s -n argocd deploy/argocd-server

# Apply Argo CD Application resource
echo "[INFO] Applying Argo CD Application..."
kubectl apply -f ./confs/argocd-app.yaml

echo "[✅ DONE] Argo CD and app setup complete."
echo "👉 Access your app at: http://localhost:8888/"

#!/bin/bash

set -e

echo "[INFO] Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
  echo "[ERROR] Homebrew is not installed. Please install it first: https://brew.sh/"
  exit 1
fi

# Install k3d if not already installed
if ! command -v k3d &> /dev/null; then
  echo "[INFO] Installing k3d..."
  brew install k3d
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
  echo "[INFO] Installing kubectl..."
  brew install kubectl
fi

# Install Argo CD CLI
if ! command -v argocd &> /dev/null; then
  echo "[INFO] Installing Argo CD CLI..."
  brew install argocd
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

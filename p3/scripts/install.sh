#!/bin/bash

# Create cluster
k3d cluster delete my-cluster || true
k3d cluster create my-cluster

# Create namespaces
kubectl create namespace argocd || true
kubectl create namespace dev || true

# Install Argo CD
echo "[INFO] Installing Argo CD into Kubernetes..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Waiting for Argo CD server to be ready..."
kubectl wait --for=condition=available --timeout=180s -n argocd deploy/argocd-server

# Apply Argo CD Application resource (points to your GitHub repo)
kubectl apply -f ./confs/argocd-app.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
#!/bin/bash

k3d cluster delete my-cluster
k3d cluster create my-cluster -p "9000:8888@loadbalancer"

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=available --timeout=180s -n argocd deploy/argocd-server

kubectl apply -f ./p3/confs/argocd-app.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
#!/bin/bash

# Exit the script immediately if any command fails
# (i.e., returns a non-zero exit code).
set -e

# Create K3d cluster with NodePort 30202 exposed to host on port 8888
echo "[INFO] Creating K3d cluster..."
k3d cluster create bonus

# Create namespaces
kubectl create namespace argocd || true
kubectl create namespace dev || true

# MAKE SURE helm exists
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# install gitlab with localhost config
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --create-namespace \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=127.0.0.1 \
  --set certmanager-issuer.email=you@example.com \
  --timeout 600s

# Modify the /etc/hosts
# 127.0.0.1       gitlab.example.com


# wait for deployment ready
# kubectl wait --for=condition=available deployments --all -n gitlab


# Get credentials 
# username => root
# password => kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath="{.data.password}" | base64 --decode

# Port forwarding 
# SHOULD BE DYNAMIC
# kubectl port-forward gitlab-nginx-ingress-controller-5597589d49-2hcf4 -n gitlab 9000:443 > /dev/null 2>&1 &
# kubectl port-forward \
#   -n gitlab \
#   $(kubectl get pods -n gitlab -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}') \
#   9000:443 > /dev/null 2>&1 &


# Step 1: Get root password
# echo "[INFO] Getting GitLab root password..."
# GITLAB_ROOT_PASSWORD=$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath="{.data.password}" | base64 --decode)

# # Step 2: Wait for GitLab to be reachable
# echo "[INFO] Waiting for GitLab to respond..." 
# # ???
# until curl -k --silent --output /dev/null --fail https://localhost:9000/users/sign_in; do
#   echo "Waiting for GitLab to be up..."
#   sleep 5
# done

# # Step 3: Login and get a personal access token using GitLab API
# echo "[INFO] Getting GitLab root token..."
# GITLAB_TOKEN=$(curl -k --request POST "https://localhost:9000/api/v4/session" \
#   --header "Content-Type: application/json" \
#   --data "{\"login\":\"root\",\"password\":\"$GITLAB_ROOT_PASSWORD\"}" \
#   | jq -r '.private_token')

# # Fallback if /session is disabled (alternative way using PAT creation API — optional)

# # Step 4: Create project
# REPO_NAME="my-app"
# echo "[INFO] Creating GitLab project $REPO_NAME..."
# curl -k --request POST "https://localhost:9000/api/v4/projects" \
#   --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
#   --data "name=$REPO_NAME&visibility=private"

# # Step 5: Push your local manifests to GitLab
# echo "[INFO] Pushing local manifests to GitLab repo..."
# GIT_REPO_URL="https://root:$GITLAB_TOKEN@localhost:9000/root/$REPO_NAME.git"

# rm -rf /tmp/$REPO_NAME
# mkdir -p /tmp/$REPO_NAME
# cp -r ./confs/manifests/* /tmp/$REPO_NAME

# cd /tmp/$REPO_NAME
# git init
# git remote add origin "$GIT_REPO_URL"
# git checkout -b main
# git add .
# git commit -m "Initial commit"
# git push -u origin main
# cd -



# Install Argo CD
# echo "[INFO] Installing Argo CD into Kubernetes..."
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# echo "[INFO] Waiting for Argo CD server to be ready..."
# kubectl wait --for=condition=available --timeout=180s -n argocd deploy/argocd-server

# # Apply Argo CD Application resource (points to your GitHub repo)
# echo "[INFO] Applying Argo CD Application..."
# kubectl apply -f ./confs/argocd-app.yaml

# echo "[✅ DONE] K3d cluster and Argo CD are ready."
# echo "👉 Your app will be available at: http://localhost:8888/"

# kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
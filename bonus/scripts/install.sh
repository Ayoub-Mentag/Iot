#!/bin/bash

GITLAB_HOST="gitlab.local"
GITLAB_PORT="9500"
PROJECT_NAME="amentag-manifest"
USERNAME="root"
EMAIL="ayoubmentag21@gmail.com"
LOCAL_PROJECT_PATH="/root/home/amentag-manifest"

# Cluster creation
rm -rf /root/home/amentag-manifest/.git
k3d cluster delete my-cluster
k3d cluster create my-cluster -p "9000:8888@loadbalancer"
kubectl create namespace gitlab
kubectl create namespace argocd
kubectl create namespace dev

# Configure gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values /root/home/Iot/bonus/confs/gitlab-values.yaml \
  --timeout 600s

while true; do
  NOT_READY=$(kubectl get pods -n gitlab --no-headers | grep -vE 'Running|Completed' | wc -l)
  
  if [ "$NOT_READY" -eq 0 ]; then
    echo "All GitLab pods are running or completed."
    break
  else
    echo "Waiting... ($NOT_READY pods not ready)"
    sleep 10
  fi
done


kubectl port-forward -n gitlab svc/gitlab-webservice-default 9500:8181 > /dev/null 2>&1 &


# Generate GitLab Personal Access Token 
GITLAB_TOKEN=$(kubectl exec -n gitlab deploy/gitlab-toolbox -- \
  gitlab-rails runner \
  "token = PersonalAccessToken.create!(user: User.find_by_username('$USERNAME'), name: 'automation-token', scopes: [:api, :read_repository], expires_at: 30.days.from_now); puts token.token")

if [ -z "$GITLAB_TOKEN" ]; then
  echo "Failed to generate GitLab token"
  exit 1
fi

# Configure Git and Push ===
cd $LOCAL_PROJECT_PATH
git config --global user.email "$EMAIL"
git config --global user.name "$USERNAME"
git init
GIT_REMOTE="http://${USERNAME}:${GITLAB_TOKEN}@${GITLAB_HOST}:${GITLAB_PORT}/${USERNAME}/${PROJECT_NAME}.git"
git remote add origin "$GIT_REMOTE"

git add .
git commit -m "Initial commit"

echo "Waiting for GitLab web interface to become available..."
until curl -s -o /dev/null -w "%{http_code}" "http://${GITLAB_HOST}:${GITLAB_PORT}/users/sign_in" | grep -q "200"; do
  echo "GitLab not ready yet. Retrying in 10s..."
  sleep 10
done

git push -u origin master

# Configure argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
ARGOCD_SECRET=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
echo "Waiting for Argo CD API to be ready..."
until curl -s -k https://localhost:8080/healthz | grep "ok" >/dev/null; do
  sleep 2
done

argocd login localhost:8080 --username admin --password $ARGOCD_SECRET --insecure
argocd repo add http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/amentag-manifest.git --username root  --password $GITLAB_TOKEN --insecure-skip-server-verification
kubectl apply -f /root/home/Iot/bonus/confs/argocd.yaml
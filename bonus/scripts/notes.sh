# Generate token
TOOLBOX_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath="{.items[0].metadata.name}")
GITLAB_TOKEN=$(kubectl exec -n gitlab "$TOOLBOX_POD" -- gitlab-rails runner \
"token = PersonalAccessToken.create!(user: User.find_by_username('root'), name: 'automation-token', scopes: [:api], expires_at: 30.days.from_now); puts token.token")

# Create an ssh-key
PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
curl --insecure --request POST "https://gitlab.example.com:9000/api/v4/user/keys" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{\"title\": \"automation-key\", \"key\": \"$PUB_KEY\"}"


# Create repo
curl --insecure --request POST "https://gitlab.example.com:9000/api/v4/projects" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "amentag-manifest",
    "visibility": "private"
  }'
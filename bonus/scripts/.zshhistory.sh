# install pre-requirements
sudo apt install ca-certificates curl openssh-server postfix tzdata perl
cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
less /tmp/script.deb.sh
sudo bash /tmp/script.deb.sh
sudo apt install gitlab-ce
sudo ufw status
sudo ufw allow http\
sudo ufw allow https\
sudo ufw allow OpenSSH
sudo ufw status
sudo ufw activated
sudo ufw activate
sudo ufw enable
ufw status


# Modify config
cat /etc/gitlab/gitlab.rb\
letsencrypt['enable'] = false
external_url 'http://gitlab.local'

# Login with curl
# code /etc/gitlab/initial_root_password\
csrf_token=$(grep -Po '(?<=name="authenticity_token" value=")[^"]*' login.html)\
curl -b cookies.txt -c cookies.txt -X POST http://gitlab.local/users/sign_in \\
  -d "user[login]=root" \\
  -d "user[password]=amentag" \\
  -d "authenticity_token=$csrf_token" \\
  -L


# generate token
GITLAB_TOKEN=$(sudo gitlab-rails runner \
"token = PersonalAccessToken.create!(user: User.find_by_username('root'), name: 'automation-token', scopes: [:api], expires_at: 30.days.from_now); puts token.token")

# PUB KEY
ssh-keygen -t rsa -b 4096 -C "ayoubmentag21@gmail.com"
PUB_KEY=$(cat /root/.ssh/id_rsa.pub)

# create key
curl --insecure --request POST "http://gitlab.local/api/v4/user/keys" --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --header "Content-Type: application/json" --data "{\"title\": \"automation-key\", \"key\": \"$PUB_KEY\"}"

# create repo 
curl --insecure --request POST "http://gitlab.local/api/v4/projects" \\
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \\
  --header "Content-Type: application/json" \\
  --data '{\
    "name": "amentag-manifest",\
    "visibility": "private"\
  }'

# clone repo and push to it
git config --global user.email "ayoubmentag21@gmail.com"
git config --global user.name "Ayoub-Mentag"
git add .
git commit -m "First commit"
git push



#!/bin/bash

START=$(date +%s)

# install some necessary packages
apt update
apt install net-tools
apt install zsh -y
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install K3s in controller mode
curl -sfL https://get.k3s.io | sh -

# Save the token to a shared directory so the worker can access it
mkdir -p /vagrant/shared
cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/token
ln -sf /usr/local/bin/kubectl /usr/bin/kubectl
chown vagrant /etc/rancher/k3s/k3s.yaml
kubectl apply -f /vagrant/configs --recursive


END=$(date +%s)
echo "⏱️ Provisioning script ran for $(($END - $START)) seconds"

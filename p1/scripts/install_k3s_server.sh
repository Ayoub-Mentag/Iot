#!/bin/bash

START=$(date +%s)

# Install K3s in controller mode
curl -sfL https://get.k3s.io | sh -

# Save the token to a shared directory so the worker can access it
mkdir -p /vagrant/shared
cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/token
ln -sf /usr/local/bin/kubectl /usr/bin/kubectl
chown vagrant /etc/rancher/k3s/k3s.yaml
apt update && apt install net-tools
END=$(date +%s)
echo "⏱️ Provisioning script ran for $(($END - $START)) seconds"

#!/bin/bash
START=$(date +%s)

# Wait for the server token to exist
while [ ! -f /vagrant/shared/token ]; do
  echo "Waiting for token..."
  sleep 2
done

# Install some necessary packages
apt update
apt install net-tools

# Install K3s in agent mode
K3S_URL="https://192.168.56.110:6443"
K3S_TOKEN=$(cat /vagrant/shared/token)
curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -
ln -s /usr/local/bin/kubectl /usr/bin/kubectl
END=$(date +%s)
echo "⏱️ Provisioning script ran for $(($END - $START)) seconds"
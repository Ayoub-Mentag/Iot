#!/bin/bash

# Wait for the server token to exist
while [ ! -f /vagrant/shared/token ]; do
  echo "Waiting for token..."
  sleep 2
done

# Install K3s in agent mode
K3S_URL="192.168.56.110"
K3S_TOKEN=$(cat /vagrant/shared/token)
curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -

ln -s /usr/local/bin/kubectl /usr/bin/kubectl
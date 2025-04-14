#!/bin/bash

# Install K3s in controller mode
curl -sfL https://get.k3s.io | sh -

# Save the token to a shared directory so the worker can access it
mkdir -p /vagrant/shared
cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/token

ln -s /usr/local/bin/kubectl /usr/bin/kubectl
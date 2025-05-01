#!/bin/bash

START=$(date +%s)

# install some necessary packages
apt update
apt install net-tools

# Install K3s in controller mode
curl -sfL https://get.k3s.io | sh -

# apply k3s configs
kubectl apply -f /vagrant/configs --recursive

END=$(date +%s)
echo "⏱️ Provisioning script ran for $(($END - $START)) seconds"

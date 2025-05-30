#!/bin/bash

apt update
apt install net-tools

curl -sfL https://get.k3s.io | sh -

mkdir -p /vagrant/shared
cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/token
ln -sf /usr/local/bin/kubectl /usr/bin/kubectl
chown vagrant /etc/rancher/k3s/k3s.yaml
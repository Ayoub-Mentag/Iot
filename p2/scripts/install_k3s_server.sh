#!/bin/bash

apt update
apt install net-tools

curl -sfL https://get.k3s.io | sh -
chown vagrant /etc/rancher/k3s/k3s.yaml
kubectl apply -f /vagrant/configs --recursive
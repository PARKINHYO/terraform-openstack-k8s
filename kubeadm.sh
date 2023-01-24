#!/bin/sh

sleep 20

sudo kubeadm init \
--token abcdef.1234567890abcdef \
--token-ttl 0 \
--control-plane-endpoint="$(hostname -I | sed 's/.\{1\}$//')":6443 \
--pod-network-cidr=10.244.0.0/16

sleep 20

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

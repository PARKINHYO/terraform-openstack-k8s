#!/bin/sh

sleep 10

sudo kubeadm init \
--control-plane-endpoint="$(hostname -I | sed 's/.\{1\}$//')":6443 \
--pod-network-cidr=10.244.0.0/16

sleep 10

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

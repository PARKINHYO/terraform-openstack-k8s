#!/bin/sh

sleep 5
sudo kubeadm init \
--token abcdef.1234567890abcdef \
--token-ttl 0 \
--control-plane-endpoint="$(hostname -I | sed 's/.\{1\}$//')":6443 \
--pod-network-cidr=10.244.0.0/16

sleep 5
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 3
echo -e "\n\n# kubectl alias\nalias k='kubectl'" >> ~/.bashrc

sleep 3
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

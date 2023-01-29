#!/usr/bin/env bash

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
kubectl apply -f https://raw.githubusercontent.com/PARKINHYO/Dockerfile/main/calico.yaml

sleep 10
kubectl get configmap kube-proxy -n kube-system -o yaml > kube-proxy.yaml
sed -i "s/strictARP: false/strictARP: true/g" kube-proxy.yaml
kubectl apply -f kube-proxy.yaml

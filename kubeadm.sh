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
kubectl apply -f http://www.eg-playground.xyz:5922/calico.yaml
sleep 10

kubectl get configmap kube-proxy -n kube-system -o yaml > kube-proxy.yaml
sed -i "s/strictARP: false/strictARP: true/g" kube-proxy.yaml
kubectl apply -f kube-proxy.yaml

sudo cat <<EOF > metallb-ippool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.0.0.200-10.0.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

sleep 10
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl delete validatingwebhookconfigurations metallb-webhook-configuration
kubectl apply -f metallb-ippool.yaml

#!/usr/bin/env bash

sudo apt-get install git -y

function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

box_out $@ 'Welcome to parkinhyo kubernetes monitoring system!!' \
'' 'kubernetes resource list' '* metrics-server' \
'* kube-state-metrics' '* node-exporter' \
'* prometheus-operator, prometheus, prometheus-permission' \
'* serviceMonitor: node-exporter, kube-state, kubelet' \
'* grafana'

sleep 5

box_out $@ 'metrics-server resource apply...'
sleep 1
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sed -i'' -r -e "/        - --secure-port=4443/a\        - --kubelet-insecure-tls" components.yaml
sed -i'' -r -e "/  - nodes\/metrics/a\  - nodes/stats" components.yaml
kubectl apply -f components.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'metrics-server resource apply complete..!!'
sleep 1

box_out $@ 'kube-state-metrics resource apply...'
git clone https://github.com/kubernetes/kube-state-metrics.git
kubectl apply -f ./kube-state-metrics/examples/standard
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'kube-state-metrics resource apply complete..!!'
sleep 1

box_out $@ 'node-exporter resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/ce1e9c6c931f4821ec0aa35b9ffdf875/raw/\
3ad6f416dd1fa668376a332b26b35c851db2cec8/node-exporter.yaml
kubectl apply -f node-exporter.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'node-exporter resource apply complete..!!'
sleep 1

box_out $@ 'prometheus-operator resource apply...'
sleep 1
wget https://github.com/prometheus-operator/prometheus-operator/raw/main/bundle.yaml
mv bundle.yaml prometheus-operator.yaml
kubectl create -f prometheus-operator.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'prometheus-operator resource apply complete..!!'
sleep 1

box_out $@ 'prometheus resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/555143514aa15b41147bbf5c07ae656a/raw/\
42bd77409072f93754b8bc2f1833f9d098eebd86/prometheus-simple.yaml
kubectl apply -f prometheus-simple.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'prometheus resource apply complete..!!'
sleep 1

box_out $@ 'prometheus-permission resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/e444c8816489185f756a70f20fb3fb9b/raw/\
a22005ddb0433d34d4dfb2980b99e423e1ff8c85/prometheus-permission.yaml
kubectl apply -f prometheus-permission.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'prometheus-permission resource apply complete..!!'
sleep 1

box_out $@ 'node-exporter-serviceMonitor resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/122fb0fc9eb32bc9a19702d0ea77f709/raw/\
04b72c7e481aef82a7fd4958c5e803771731322c/node-exporter-serviceMonitor.yaml
kubectl apply -f node-exporter-serviceMonitor.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'node-exporter-serviceMonitor resource apply complete..!!'
sleep 1

box_out $@ 'kube-state-serviceMonitor resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/6c521dbcd14b8a3e299893d8168386a5/raw/\
65365551efe9d4dc49d666c0377954b615efe9a3/kube-state-metrics-serviceMonitor.yaml
kubectl apply -f kube-state-metrics-serviceMonitor.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'kube-state-serviceMonitor resource apply complete..!!'
sleep 1

box_out $@ 'kubelet-serviceMonitor resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/7e663876048471333073bf939703c889/raw/\
92034fd05aa1c451a9d88e6e4e708da3f9f536f5/kubelet-serviceMonitor.yaml
kubectl apply -f kubelet-serviceMonitor.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'kubelet-serviceMonitor resource apply complete..!!'
sleep 1

box_out $@ 'grafana resource apply...'
sleep 1
wget https://gist.githubusercontent.com/PARKINHYO/13840ac9c7ef3c7058ae4ee55675ebf9/\
raw/fe35f229741f024867b4b5be6c66e64e019367b1/grafana.yaml
kubectl apply -f grafana.yaml
box_out $@ 'wait 30sec...'
sleep 30
box_out $@ 'grafana resource apply complete..!!'
sleep 1

box_out $@ 'parkinhyo kubernetes monitoring system apply completed!!' 'congratulation~!!'
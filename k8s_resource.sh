#!/usr/bin/env bash

wget https://github.com/PARKINHYO/Dockerfile/raw/main/monitoring.tar
tar -xvf monitoring.tar
sudo chmod -R 755 /home/ubuntu/prometheus_grafana
cd /home/ubuntu/prometheus_grafana
sh install_monitoring.sh
sleep 300

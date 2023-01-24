#!/bin/sh

sleep 5

echo $1

sudo kubeadm join $1:6443 \
--token abcdef.1234567890abcdef \
--discovery-token-unsafe-skip-ca-verification

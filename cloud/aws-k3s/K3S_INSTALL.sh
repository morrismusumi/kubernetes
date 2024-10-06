#!/bin/bash

if [ ${count_index} -eq 0 ]; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san k3s.aws.homekube.io" K3S_TOKEN=12345 sh -s - server --cluster-init | tee -a /tmp/k3s.txt
fi

if [ ${count_index} -eq 1 ]; then
  ETCD_0=down
  while [[ "$ETCD_0" == "down" ]]; do 
    curl --connect-timeout 3 -k https://10.0.1.100:6443 && ETCD_0=up || ETCD_0=down
  done
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san k3s.aws.homekube.io" K3S_TOKEN=12345 sh -s - server --token 12345 --server https://10.0.1.100:6443 | tee -a /tmp/k3s.txt
fi
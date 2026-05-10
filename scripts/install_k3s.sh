#!/bin/bash

set -e

echo "======================================="
echo "Installing k3s cluster"
echo "======================================="

curl -sfL https://get.k3s.io | sh -

echo ""
echo "======================================="
echo "Configuring kubeconfig"
echo "======================================="

mkdir -p $HOME/.kube

sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config

echo ""
echo "======================================="
echo "Waiting for cluster startup"
echo "======================================="

sleep 20

echo ""
echo "======================================="
echo "Cluster Nodes"
echo "======================================="

kubectl get nodes

echo ""
echo "======================================="
echo "System Pods"
echo "======================================="

kubectl get pods -A

echo ""
echo "======================================="
echo "k3s installation completed"
echo "======================================="

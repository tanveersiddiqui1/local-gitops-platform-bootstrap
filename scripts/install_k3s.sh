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

# Wait for k3s to be ready
echo "Waiting for k3s service to start..."
sleep 30

# Wait for API server to be responsive
echo "Waiting for Kubernetes API server..."
for i in {1..30}; do
  if kubectl cluster-info >/dev/null 2>&1; then
    echo "API server is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 10
done

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "ERROR: Kubernetes API server did not become ready"
  exit 1
fi

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

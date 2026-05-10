#!/bin/bash

set -e

echo "======================================="
echo "Removing k3s cluster"
echo "======================================="

sudo /usr/local/bin/k3s-uninstall.sh || true

rm -rf $HOME/.kube

echo ""
echo "======================================="
echo "k3s removed successfully"
echo "======================================="

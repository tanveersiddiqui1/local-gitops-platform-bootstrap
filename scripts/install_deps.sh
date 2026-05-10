#!/bin/bash

set -e

echo "======================================="
echo "Installing WSL dependencies for bootstrap"
echo "======================================="

sudo apt update
sudo apt install -y curl gnupg software-properties-common apt-transport-https ca-certificates make git

# Install Terraform from HashiCorp repository
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y terraform

# Install kubectl via the official release binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo ""
echo "======================================="
echo "WSL dependency installation completed"
echo "======================================="
``
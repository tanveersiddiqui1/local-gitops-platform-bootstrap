#!/usr/bin/env bash

set -euo pipefail

echo "======================================="
echo "Bootstrapping FluxCD"
echo "======================================="

# --------------------------------------------------
# Configuration
# --------------------------------------------------

GITHUB_OWNER="${GITHUB_OWNER:-tanveersiddiqui1}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-local-gitops-platform-bootstrap}"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"

# Flux manifests will be stored here in the Git repository
FLUX_PATH="${FLUX_PATH:-clusters/local}"

# k3s kubeconfig
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# --------------------------------------------------
# Validate prerequisites
# --------------------------------------------------

echo
echo "======================================="
echo "Checking prerequisites"
echo "======================================="

if ! command -v kubectl >/dev/null 2>&1; then
    echo "[ERROR] kubectl is not installed."
    exit 1
fi

if ! command -v flux >/dev/null 2>&1; then
    echo "[ERROR] Flux CLI is not installed."
    echo
    echo "Install it using:"
    echo "  curl -s https://fluxcd.io/install.sh | sudo bash"
    exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "[ERROR] GITHUB_TOKEN is not set."
    echo
    echo "Set it before running this script:"
    echo "  export GITHUB_TOKEN=<your-token>"
    exit 1
fi

# --------------------------------------------------
# Verify Kubernetes cluster
# --------------------------------------------------

echo
echo "======================================="
echo "Checking Kubernetes cluster"
echo "======================================="

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "[ERROR] Kubernetes cluster is not reachable."
    echo
    echo "Check:"
    echo "  kubectl get nodes"
    exit 1
fi

kubectl get nodes

# --------------------------------------------------
# Verify GitHub connectivity
# --------------------------------------------------

echo
echo "======================================="
echo "Checking GitHub authentication"
echo "======================================="

if ! flux check --pre; then
    echo
    echo "[ERROR] Flux pre-flight checks failed."
    exit 1
fi

# --------------------------------------------------
# Bootstrap Flux
# --------------------------------------------------

echo
echo "======================================="
echo "Bootstrapping FluxCD"
echo "======================================="

flux bootstrap github \
    --token-auth \
    --owner="${GITHUB_OWNER}" \
    --repository="${GITHUB_REPOSITORY}" \
    --branch="${GITHUB_BRANCH}" \
    --path="${FLUX_PATH}" \
    --personal

# --------------------------------------------------
# Verify Flux
# --------------------------------------------------

echo
echo "======================================="
echo "Verifying Flux installation"
echo "======================================="

flux check

echo
echo "======================================="
echo "Flux Controllers"
echo "======================================="

kubectl get pods -n flux-system

echo
echo "======================================="
echo "Flux Bootstrap Complete"
echo "======================================="

echo
echo "GitHub Repository:"
echo "  ${GITHUB_OWNER}/${GITHUB_REPOSITORY}"

echo
echo "Flux Path:"
echo "  ${FLUX_PATH}"

echo
echo "Kubernetes Namespace:"
echo "  flux-system"

echo
echo "======================================="

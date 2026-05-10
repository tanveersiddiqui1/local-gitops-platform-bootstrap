# Local GitOps Platform Bootstrap

Bootstrap repository for provisioning a local k3s Kubernetes cluster on WSL2 using Terraform.

---

## Objective

This repository is responsible ONLY for:

- Installing k3s
- Configuring kubectl access
- Bootstrapping a reproducible local Kubernetes cluster

Future responsibilities such as:
- FluxCD
- Jenkins
- Argo Workflows
- Helm releases
- GitOps reconciliation

will be managed separately.

---

## Architecture

Windows
↓
WSL2 Ubuntu
↓
k3s Kubernetes Cluster

---

## Repository Structure

terraform/
Terraform orchestration layer

scripts/
Bootstrap shell scripts

---

## Prerequisites

- Windows with WSL2
- Ubuntu WSL distribution
- sudo access
- Internet connectivity

---

## Install Dependencies

Before bootstrapping the cluster, install required WSL dependencies:

```bash
bash scripts/install_deps.sh
```

---

## Bootstrap Cluster

```bash
make bootstrap
```

---

## Verify Cluster

```bash
kubectl get nodes

kubectl get pods -A
```

---

## Destroy Cluster

```bash
make destroy
```

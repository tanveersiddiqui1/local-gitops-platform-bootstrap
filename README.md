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

```
local-gitops-platform-bootstrap/
├── README.md                    # This documentation
├── .gitignore                   # Ignore Terraform state and lock files
├── Makefile                     # Convenience commands for bootstrap/destroy
├── terraform/                   # Terraform orchestration
│   ├── main.tf                  # Null resource to run install script
│   ├── variables.tf             # Cluster name variable
│   ├── outputs.tf               # Bootstrap status outputs
│   └── versions.tf              # Terraform version constraints
└── scripts/                     # Installation and cleanup scripts
    ├── install_deps.sh          # Install WSL dependencies
    ├── install_k3s.sh           # Install and configure k3s
    └── uninstall_k3s.sh         # Remove k3s completely
```

---

## Troubleshooting

### kubectl connection refused
- Ensure `KUBECONFIG` is set: `export KUBECONFIG=$HOME/.kube/config`
- Check k3s service: `sudo systemctl status k3s`
- Restart if needed: `sudo systemctl restart k3s`

### WSL cgroup issues
- Uses k3s v1.30.2+k3s1 (cgroup v1 compatible)
- If issues persist, consider k3d (k3s in Docker)

### Terraform state issues
- Run `make destroy` to clean state
- Then `make bootstrap` to recreate

---

## Next Steps

This repository provides the foundation. Future enhancements:
- FluxCD bootstrap for GitOps
- Application deployments (Jenkins, Artifactory, etc.)
- Monitoring with New Relic
- Helm/Kustomize management

Each will be added as separate Terraform resources or scripts.

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

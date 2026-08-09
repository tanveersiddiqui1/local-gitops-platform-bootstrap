# Local GitOps Platform Bootstrap

Bootstrap repository for provisioning and configuring a local **k3s Kubernetes cluster on WSL2** using Terraform and shell scripts.

The repository provides the foundation for a local GitOps platform and is designed to be **reproducible, idempotent, and easy to destroy and recreate**.

---

## Objective

This repository is responsible for the initial platform bootstrap:

* Installing required WSL dependencies
* Installing k3s
* Configuring kubectl access
* Bootstrapping a reproducible local Kubernetes cluster
* Bootstrapping FluxCD on an existing Kubernetes cluster
* Connecting FluxCD to the GitOps repository

Future platform components such as:

* Jenkins
* Argo Workflows
* Helm releases
* Kyverno
* Istio
* Karpenter
* New Relic
* Other platform services

will be managed through GitOps after FluxCD has been bootstrapped.

---

## Architecture

```text
Windows
   │
   ▼
WSL2 Ubuntu
   │
   ▼
Terraform
   │
   ▼
k3s Kubernetes Cluster
   │
   ▼
FluxCD
   │
   ▼
GitHub GitOps Repository
   │
   ▼
Kubernetes Resources
```

The intended workflow is:

```text
Cluster Creation
       │
       ▼
    k3s
       │
       ▼
 Flux Bootstrap
       │
       ▼
    GitHub
       │
       ▼
   GitOps Sync
       │
       ▼
Platform Components
```

---

## Repository Structure

```text
local-gitops-platform-bootstrap/
├── README.md                         # Repository documentation
├── .gitignore                        # Git ignore rules
├── Makefile                          # Convenience commands
│
├── terraform/                        # Terraform orchestration
│   ├── main.tf                       # Runs k3s installation
│   ├── variables.tf                  # Terraform variables
│   ├── outputs.tf                    # Bootstrap outputs
│   ├── versions.tf                   # Terraform/provider constraints
│   └── .terraform.lock.hcl           # Provider dependency lock file
│
└── scripts/
    ├── install_deps.sh               # Install WSL dependencies
    ├── install_k3s.sh                # Install and configure k3s
    ├── uninstall_k3s.sh              # Remove k3s
    └── bootstrap_flux.sh             # Bootstrap FluxCD
```

---

## Prerequisites

The following are required:

* Windows
* WSL2
* Ubuntu WSL distribution
* sudo access
* Internet connectivity
* Git
* Terraform
* kubectl
* GitHub repository access
* GitHub Personal Access Token for Flux bootstrap

---

## WSL Development Model

The recommended development model is:

```text
Windows
   │
   ├── VS Code
   │
   └── WSL2
        │
        └── Ubuntu
             │
             └── Repository
```

The repository should preferably be operated from WSL.

Example:

```bash
cd /mnt/d/MyLearning/gitRepos/local-gitops-platform-bootstrap
```

VS Code can be used for editing, while commands such as Terraform, kubectl, Git, and shell scripts are executed from WSL.

---

## Install Dependencies

Before creating the cluster:

```bash
bash scripts/install_deps.sh
```

This installs the dependencies required by the local k3s environment.

---

# Cluster Lifecycle

## Create the Cluster

For a new environment:

```bash
make cluster-create
```

This performs:

```text
Terraform init
       │
       ▼
Terraform apply
       │
       ▼
install_k3s.sh
       │
       ▼
k3s cluster
```

Terraform is responsible for orchestrating the k3s installation.

---

## Bootstrap Everything

On a fresh environment, the complete bootstrap can be executed using:

```bash
make bootstrap
```

The intended workflow is:

```text
make bootstrap
      │
      ├── Create k3s cluster
      │
      └── Bootstrap FluxCD
```

This should be used when setting up the environment from scratch.

---

## Bootstrap FluxCD on an Existing Cluster

If the k3s cluster is already running, **do not run the cluster creation step again**.

Instead:

```bash
make flux-bootstrap
```

This executes:

```bash
bash scripts/bootstrap_flux.sh
```

The Flux bootstrap script is designed to:

1. Verify Kubernetes connectivity
2. Verify the Flux CLI
3. Validate the required GitHub configuration
4. Bootstrap FluxCD
5. Connect FluxCD to the GitHub repository
6. Verify Flux controllers
7. Verify GitRepository/Kustomization reconciliation

This separation allows FluxCD to be installed independently from cluster creation.

---

## Verify Cluster

Check the Kubernetes nodes:

```bash
kubectl get nodes
```

Check all pods:

```bash
kubectl get pods -A
```

Check namespaces:

```bash
kubectl get ns
```

A healthy cluster should show the node as:

```text
Ready
```

and the core Kubernetes components should eventually reach:

```text
Running
```

---

# FluxCD

FluxCD is responsible for the GitOps layer of the platform.

The bootstrap process connects the Kubernetes cluster to the GitHub repository containing the desired platform configuration.

Conceptually:

```text
GitHub
   │
   │ GitOps configuration
   ▼
FluxCD
   │
   │ Reconciliation
   ▼
Kubernetes
```

After FluxCD is successfully bootstrapped, platform components can be added to the GitOps repository instead of being manually installed into the cluster.

---

## Verify FluxCD

Check Flux components:

```bash
kubectl get pods -n flux-system
```

Check Flux resources:

```bash
flux get all
```

Check GitRepository resources:

```bash
flux get sources git
```

Check Kustomizations:

```bash
flux get kustomizations
```

---

# Destroy the Cluster

To completely remove the local k3s cluster:

```bash
make destroy
```

The intended sequence is:

```text
Terraform destroy
       │
       ▼
Terraform-managed resources removed
       │
       ▼
uninstall_k3s.sh
       │
       ▼
k3s removed
```

Because FluxCD runs **inside the Kubernetes cluster**, destroying the k3s cluster also removes:

* FluxCD controllers
* FluxCD configuration
* Kubernetes workloads
* Kubernetes resources
* Cluster-local state

The GitHub GitOps repository is **not** destroyed.

Therefore, after destroying the cluster, the environment can be recreated from the Git repository.

---

# Recreate the Environment

The expected recovery workflow is:

```bash
make destroy
```

Then:

```bash
make bootstrap
```

This should result in:

```text
Fresh WSL environment
        │
        ▼
      k3s
        │
        ▼
    FluxCD
        │
        ▼
 GitHub GitOps repository
        │
        ▼
 Platform configuration
```

The goal is that the local platform can be repeatedly destroyed and recreated without manually configuring every component.

---

# Troubleshooting

## kubectl Connection Refused

Check whether k3s is running:

```bash
sudo systemctl status k3s --no-pager
```

Check whether k3s exists:

```bash
which k3s
```

Check the node:

```bash
kubectl get nodes
```

If the kubeconfig is not configured:

```bash
export KUBECONFIG=$HOME/.kube/config
```

---

## k3s Service Missing

Check:

```bash
sudo systemctl status k3s --no-pager
```

If the service does not exist, the k3s installation may have been removed.

Recreate the cluster with:

```bash
make cluster-create
```

---

## Terraform Provider Error

If Terraform reports:

```text
Required plugins are not installed
```

initialize Terraform:

```bash
cd terraform
terraform init
```

or simply use:

```bash
make cluster-create
```

The Makefile initializes Terraform before applying the configuration.

---

## Terraform Initialization After WSL Shutdown

`wsl --shutdown` or shutting down Windows does **not** destroy the Terraform configuration or cluster by itself.

Terraform is not a continuously running service.

Terraform only runs when you execute a Terraform command.

The `.terraform` directory contains locally cached provider plugins. If that directory is removed or unavailable, Terraform may need:

```bash
terraform init
```

before the next Terraform operation.

The recommended approach is therefore to keep initialization in the Makefile so that commands are resilient to a fresh WSL environment.

---

## WSL Shutdown vs Cluster Destruction

Closing the Ubuntu terminal does **not** destroy the k3s cluster.

Similarly, shutting down Windows does not intentionally destroy the cluster.

WSL is stopped, and k3s stops with it.

When WSL starts again, the k3s systemd service can start again.

To check:

```bash
sudo systemctl status k3s --no-pager
```

The cluster should still exist unless it was explicitly destroyed using:

```bash
make destroy
```

---

# Makefile Commands

The primary commands are:

```bash
make cluster-create
```

Creates the k3s cluster.

```bash
make flux-bootstrap
```

Bootstraps FluxCD into an existing cluster.

```bash
make bootstrap
```

Creates the cluster and bootstraps FluxCD.

```bash
make destroy
```

Destroys the local k3s environment.

---

# Current Platform Scope

The bootstrap repository currently focuses on:

```text
WSL2
  │
  ▼
Terraform
  │
  ▼
k3s
  │
  ▼
FluxCD
  │
  ▼
GitHub
```

Future platform components will be introduced through the GitOps layer.

Planned components include:

* Jenkins
* Argo Workflows
* Helm
* Kustomize
* Kyverno
* Istio
* Karpenter
* New Relic
* Other platform infrastructure

The objective is to minimize manual cluster configuration and make the entire platform reproducible from source control.

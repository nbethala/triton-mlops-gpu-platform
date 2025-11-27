# Infrastructure Setup : 

## Stage 0 : Setup Iam roles, Github Repo. Aws Billing alarms 

## Stage 1: setup infrastructure via terraform  

### Vpc.tf Setup : 
- 1 vpc
- 2 public subnets
- 2 private subnets
- IGW (internet gateway) 
- NAT gateway
- route tables
- confirm private subnets route outbound traffic via NAT gateway.
- Confirm public subnets route outbound traffic via Internet Gateway.

Modular Terraform Lifecycle — Folder Structure
```
infra/terraform/
├── main.tf                  # Root orchestrator
├── terraform.tfvars         # Centralized variables
├── variables.tf             # Root-level variable declarations
├── Makefile                 # Command automation
├── modules/
│   ├── vpc/                 # VPC, subnets, NAT
│   ├── iam/                 # IAM roles for EKS + GPU nodes
│   ├── eks/                 # EKS control plane
│   ├── gpu_node_group/      # GPU Spot node group (modular, teardown-ready)
│   └── alb_irsa/            # IRSA role for ALB controller (optional)
```

STEP A — Terraform / IAM cleanup & import (single source of truth)

STEP B — ECR: create repo (Terraform)
Triton image will live in ECR; enable image scan on push.

STEP C — GitHub Actions OIDC role (Terraform)
allow GitHub CI to assume a scoped role and push images to ECR without long-lived credentials.

STEP D — GitHub Actions pipeline (CI)
build and push Triton image to ECR on push to main.

GOAL -  folder will be used by GitHub Actions (CI/CD) to:

✔ Build a custom Triton Inference Server image
✔ Bundle your models
✔ Push to ECR
✔ Deploy via Helm to GPU nodes

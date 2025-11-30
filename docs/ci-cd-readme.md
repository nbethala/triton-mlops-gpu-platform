 #===========================================CI/CD Pipeline Setup ============================================# 

1️⃣ CI Pipeline — Runs on Pull Request → VALIDATION ONLY
Path:
ci/github-actions/build-push-triton.yaml

Tasks:

Lint & validate Terraform (NO APPLY)

Docker build & test Triton container (NO PUSH)

Validate Triton model repo structure

Run Python scripts like validate-model.py

Trigger:
on:
  pull_request:
    branches: [ main ]


📌 This avoids AWS cost
📌 This helps you catch mistakes BEFORE deploying
📌 This is cheap → runs only on GitHub runner

2️⃣ CD Pipeline — Runs ONLY when PR is merged → APPLY + DEPLOY
File:
ci/github-actions/deploy-infra.yaml

Tasks:

Terraform init/plan

Terraform apply

Create VPC, IAM, GPU nodes, EKS cluster

Deploy Triton Helm chart (services/triton/helm)

Deploy NVIDIA plugin

Deploy Prometheus + Grafana

Trigger:
on:
  push:
    branches: [ main ]


📌 This is when AWS resources get CREATED.
📌 This costs money — which is good because it happens only intentionally.

3️⃣ Teardown Pipeline — MANUAL workflow
File:
ci/github-actions/teardown.yaml

Tasks:

Terraform destroy

Remove all AWS resources (GPU nodes, EKS, ALB, VPC, IAM roles)

Trigger:
on:
  workflow_dispatch


(manual button in GitHub)

📌 This saves your wallet
📌 Click one button → infra gone
📌 AWS costs → back to $0 (except S3 state pennies)

🧩 How your repository fits together
Terraform modules handle:
infra/terraform/modules/eks
infra/terraform/modules/gpu_node_group
infra/terraform/modules/nvidia_plugin
infra/terraform/modules/vpc

GitHub Actions uses:

Terraform to deploy EKS + GPU nodes

Helm to deploy Triton

Helm or manifests to deploy Prometheus/Grafana

AWS OIDC for authentication (no long-lived secrets)

Services (Triton) include:
services/triton/Dockerfile
services/triton/models/
services/triton/helm/


CD pipeline will:

build image

push to ECR

update Helm values

rollout Triton Deployment

===================================
Process steps : 
====================================

phase 1: setup GITHUB OIDC role
phase 2: setup deployment for Triton 
 - A minimal GitHub Actions workflow that:
   ci/github-actions/deploy-triton.yml

 - uses OIDC to assume the GitHub role,
 - builds & tags the Triton image,
 - pushes to ECR with sha and latest tags,
 - updates kubeconfig,
 - runs helm upgrade --install to deploy Triton.
 - A full Helm chart skeleton for Triton (Chart.yaml, values.yaml, templates for Deployment, Service, ServiceAccount (IRSA), ConfigMap init sidecar, ServiceMonitor).
- Prometheus + Grafana helm install snippets + recommended values (kube-prometheus-stack + dcgm-exporter + ServiceMonitor for Triton).
- GPU monitoring dashboards: a small Grafana dashboard JSON (GPU utilization + GPU memory + Triton requests) and instructions to provision automatically.
- Slack alerts: PrometheusRule + Alertmanager config secret example to send alerts to Slack (wired via secret webhook).
- ECR image tagging & versioning: recommended tag scheme and example ECR lifecycle policy JSON to keep costs down.























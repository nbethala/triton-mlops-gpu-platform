# RUNBOOK: MLOps Triton GPU Platform Deployment
## Version 1.0 — Designed for low-cost learning, fast iteration, clean teardown

Phase 1 → Testing on feat/triton-ci-deploy

Phase 2 → Merge to main

Phase 3 → Production-style Execution (CI/CD → EKS → Triton)

============================================
PHASE 1 — Feature Branch Testing
feat/triton-ci-deploy
============================================

This phase ensures your CI/CD pipeline, image build, and Helm chart work WITHOUT running Terraform or triggering a real deployment.

✅ 1. Clone repo and switch to feature branch
git checkout -b feat/triton-ci-deploy

✅ 2. Make changes related to CI/CD

Examples:

Edit Dockerfile

Edit Helm chart

Edit GitHub Actions workflow

Edit templates/ci.json.tpl

Modify Triton model repository

Commit regularly.

✅ 3. Dry-run the GitHub Actions workflow (local check)

You don’t run the real workflow yet.

Validate YAML:

act -n -j build-push-triton


(If act is installed; optional)

✅ 4. Validate Docker build locally or on GPU node
docker build -t triton-test:local .
docker run --gpus=all -p 8000:8000 triton-test:local


Check Triton:

curl localhost:8000/v2/health/live
curl localhost:8000/v2/models

✅ 5. Validate Helm templates
helm template ./services/triton/helm


Check:

Image values

GPU resource requests

Service ports

✅ 6. Validate Terraform OIDC role (plan only)

From infra/terraform:

terraform init
terraform plan


Expected:

no actual infrastructure created

IAM role for GitHub OIDC rendered correctly using your template

🔍 Success Criteria for Phase 1

Docker build succeeds

Triton starts locally

GitHub Actions workflow has no YAML issues

Helm chart templates render

Terraform plan runs with no errors

Once all green → ready to merge.

============================================
PHASE 2 — Merge to main
============================================

This phase finalizes your tested work and enables CI/CD on the main branch.

✅ 1. Create a Pull Request

From feat/triton-ci-deploy → main.

PR should include:

What changed?

What needs testing?

Notes about Triton model changes or Helm changes.

✅ 2. Review and Approve

Since this is a learning project, you approve your own PR.

✅ 3. Merge into main

GitHub Actions will now begin running real CI/CD because your workflow is configured to trigger on:

on:
  push:
    branches: [ "main" ]

🔍 Success Criteria for Phase 2

Workflow is triggered on main

AWS OIDC authentication works

ECR login works

This confirms the CI side of CI/CD.

Next phase = deploy infra.

============================================
PHASE 3 — Execute Full Deployment on AWS
EKS + GPU Node + Prometheus + Triton
============================================

Now we run with REAL cloud resources.

🔧 STEP 1 — Deploy Infrastructure with Terraform

💡 Costs: EKS control plane + possible GPU node if enabled

From infra/terraform:

terraform init
terraform apply -auto-approve


This creates:

VPC + Subnets

EKS Cluster

GPU NodeGroup (disabled autoscaling=0 initially)

IAM roles

GitHub OIDC trust

ECR Repos

NVIDIA device plugin

🔧 STEP 2 — Add kubeconfig
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>


Check cluster:

kubectl get nodes
kubectl get pods -A

🔧 STEP 3 — Deploy Prometheus + Grafana

From monitoring folder:

helm install prom prometheus-community/kube-prometheus-stack -f values.yaml


Check:

kubectl get pods -n monitoring

🔧 STEP 4 — Scale GPU node to 1

Cheap method: scale only when needed.

terraform apply -var="gpu_capacity=1"


Confirm node:

kubectl get nodes -l gpu=true

🔧 STEP 5 — Helm Deploy Triton

From services/triton/helm:

helm upgrade --install triton ./services/triton/helm \
  --set image.tag=latest \
  --namespace mlops --create-namespace


Check Triton:

kubectl get pods -n mlops
kubectl logs <pod> -n mlops

🔧 STEP 6 — Validate Triton Endpoints
kubectl port-forward svc/triton 8000:8000 -n mlops
curl localhost:8000/v2/health/live
curl localhost:8000/v2/models

🧹 STEP 7 — TEARDOWN (IMPORTANT FOR COSTS!)
Scale GPU node to zero:
terraform apply -var="gpu_capacity=0"

Destroy all:
terraform destroy


Done — zero cost.

============================================
🎯 END STATE — CI/CD AUTO DEPLOYMENT
============================================

Once everything is merged on main and infra is up:

Full flow:
git push → GitHub Actions → Build → Push ECR → Helm Deploy → Triton Live


Every push to main deploys automatically.

🎉 This runbook gives you a full, safe, repeatable “build → deploy → teardown” workflow.

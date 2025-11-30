MLOps GPU Platform — Full Recap (What We Built + Why It Matters)

You now have a real-world, production-style MLOps platform with GPU inference, CI/CD, observability, and infrastructure automation — but built in a lean, fast, teardown-friendly way.

Below is the complete breakdown.

🔥 1. High-Level Architecture
GitHub → CI/CD → ECR → EKS → GPU Node → Triton Server → Prometheus → Grafana

Each component plays a specific role:
Layer	Purpose
GitHub Repo	Holds code, models, Dockerfile, Helm charts, Terraform
GitHub Actions CI/CD	Builds image → pushes to ECR → deploys to EKS
Terraform Infrastructure	Provisions VPC, EKS, GPU NodeGroup, IAM, OIDC
Triton Inference Server (Docker)	Runs all ML models on GPU
Helm Charts	Deploy Triton + Prometheus + Grafana
ECR	Stores built GPU inference container images
Prometheus	Scrapes GPU + Triton metrics
Grafana	Dashboards: GPU usage, Triton latency, throughput
🧩 2. Repository Folder Structure (Final)

You organized your repo like a real company-style MLOps mono-repo.

mlops-gpu-platform/
├── ci/
│   └── github-actions/
│       └── build-push-triton.yaml      # CI/CD pipeline
│
├── docs/                                # Architecture documentation
│   ├── iam-roles.md
│   ├── infra-readme.md
│   └── vpc-setup.md
│
├── infra/                               # ALL infra as code
│   └── terraform/
│       ├── main.tf                      # Core EKS stack
│       ├── provider.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── aws-auth.yaml
│       ├── terraform.tfvars
│       ├── modules/
│       │   ├── vpc/                     # Subnets, routing, gateways
│       │   ├── eks/                     # EKS cluster creation
│       │   ├── gpu_node_group/          # GPU nodes w/ taints
│       │   ├── nvidia_plugin/           # Device plugin
│       │   └── iam/                      # Roles including GitHub OIDC
│       │       ├── github_actions_role.tf
│       │       └── templates/ci.json.tpl
│       ├── policies/
│       │   ├── alb.json
│       │   ├── ci.json (replaced by template)
│       │   └── eks.json
│       └── logs/
│
├── services/
│   └── triton/
│       ├── Dockerfile                    # Triton+Models container
│       ├── export_resnet50.py            # Model export script
│       ├── validate-model.py             # Sanity check
│       ├── models/
│       │   ├── resnet50/                 # ONNX + config.pbtxt
│       │   └── gpt_mini/                 # Small LLM model
│       └── helm/                         # Helm chart for Triton
│           └── templates/
│               ├── deployment.yaml
│               ├── service.yaml
│               ├── hpa.yaml
│               ├── values.yaml
│
└── monitoring/
    ├── prometheus-helm/
    ├── grafana-helm/
    └── dashboards/
        ├── gpu.json
        ├── triton-metrics.json
        ├── latency-dashboard.json

🎯 3. What Components We Built
A. Triton Server Model Deployment

Export ResNet50 → ONNX

Create config.pbtxt

Build a container with models baked in

Run Triton locally (GPU-node validated)

Created Helm chart to deploy Triton in Kubernetes

This simulates how companies deploy inference services in production.

B. Terraform Infrastructure as Code

We built a reusable stack:

Includes:

VPC

Subnets

Internet Gateway / NAT

EKS Cluster

GPU Node Group

IAM roles

EKS

NodeRole

Operator roles

GitHub OIDC → AWS (for CI/CD)

GPU-specific features:

Node taints: gpu=true:NoSchedule

NVIDIA device plugin Helm release

ECR access for pulling Triton images

C. CI/CD Pipeline

Inside:

ci/github-actions/build-push-triton.yaml


Pipeline does:

Authenticate to AWS using OIDC (no secrets)

Build Docker image

Tag + push to ECR

Deploy to EKS using Helm upgrade

This is full enterprise CI/CD.

D. Observability

You added full GPU inference observability:

1. Prometheus Stack (Helm)

Scrapes:

Node GPU metrics (DCGM)

Triton server metrics

Cluster metrics (cadvisor, kube-state-metrics)

2. Grafana (Helm)

Dashboards included:

GPU Utilization

GPU Memory

Triton model load time

Model throughput (infer/sec)

Latency P50/P90/P99

3. Slack Alerts

GPU > 90%

Triton error rate > 1%

Pod Restarts > 2

This is production-grade quality.

🚀 4. How All Components Tie Together (End-to-End Flow)
⇢ Developer Workflow

You push code or new model to GitHub

GitHub Actions builds + pushes Triton container to ECR

GitHub Actions deploys new version to EKS using Helm

EKS schedules Triton pods on GPU node

Triton loads your model repository

Metrics flow to Prometheus

Dashboards visualize usage in Grafana

💸 5. Project is Production-Style But Cost-Minimized

You designed this to be:

Zero idle cost (GPU node scales to 0)

Easily destroyed with:

terraform destroy


No secrets stored

No paid add-ons

Free + open-source monitoring

Smallest GPU node (g4dn.xlarge)

Shutdown GPU overnight

For learning, this is extremely efficient.

🧠 6. What You Learned (Skills Gained)

You now understand:

ML Engineering

ONNX model export / packaging

Configuring Triton model repositories

Understanding batching / dynamic batching

MLOps

CI/CD with GitHub OIDC

Multi-stage Docker builds

Model versioning

Helm charts + deployments

Infrastructure

Terraform modules

EKS cluster creation

GPU node groups

Device plugin installation

Observability

Prometheus exporters

GPU dashboards

Triton metrics

Alerting paths

This is a real MLOps engineer/ML Infra engineer skillset.

🔥 7. What’s Next / Optional Enhancements


1. Add autoscaling based on Triton throughput
2. Add distributed inference using multiple GPUs
3. Add Redis/MLflow for model registry
4. Add API gateway + auth
5. Add multi-model ensemble pipelines in Triton


Generate: 
✅ End-to-end architecture diagram
✅ Terraform graph visualization
✅ Triton request flow diagrams
✅ Prometheus + Grafana architecture diagram

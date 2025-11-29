# AWS Account ID
account_id              = "478253497479"

# EKS OIDC Provider ARN (for IAM roles tied to service accounts)
eks_oidc_provider_arn   = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"

# EKS OIDC Provider Subject (service account identity)
eks_oidc_provider_sub   = "system:serviceaccount:default:triton-sa"

# GitHub OIDC Provider ARN (for GitHub Actions federation)
github_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"

# GitHub Organization or Username
github_org              = "nbethala"

# GitHub Repository Name
github_repo             = "nbethala/triton-mlops-gpu-platform"
model_bucket_name = "triton-models"
project           = "triton-mlops"

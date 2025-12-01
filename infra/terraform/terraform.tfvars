# -------------------------
# GitHub Actions OIDC (CI/CD)
# -------------------------
github_org        = "my-org"
github_repo       = "nbethala/triton-mlops-gpu-platform"
github_branch     = "main"
oidc_provider_url = "token.actions.githubusercontent.com"
project           = "triton-mlops"
oidc_provider_arn = "arn:aws:iam::478253497479:oidc-provider/token.actions.githubusercontent.com"


# -------------------------
# EKS OIDC (IRSA for pods)
# -------------------------
eks_oidc_provider_arn = "arn:aws:iam::478253497479:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
eks_oidc_provider_sub = "system:serviceaccount:default:triton-sa"


# -------------------------
# AWS Account & Region
# -------------------------
account_id = "478253497479"
region     = "us-east-1"

# -------------------------
# Resources
# -------------------------
model_bucket_name    = "triton-models"
s3_model_bucket_arns = ["arn:aws:s3:::triton-models"]

ecr_repo_arns    = ["arn:aws:ecr:us-east-1:478253497479:repository/triton-infer"]
cluster_name     = "mlops-gpu-eks"
eks_cluster_arns = ["arn:aws:eks:us-east-1:478253497479:cluster/mlops-gpu-eks"]

node_role_arns = []

# -------------------------
# Tags
# -------------------------
common_tags = {
  owner   = "nancy"
  project = "triton-mlops"
  env     = "dev"
}

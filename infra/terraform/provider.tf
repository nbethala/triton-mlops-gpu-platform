# -----------------------------------------------------
# AWS provider config
# -----------------------------------------------------
provider "aws" {
  region = var.region
}

# -----------------------------------------------------
# Data sources: pull cluster details
# -----------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# -----------------------------------------------------
# Kubernetes provider wired to EKS
# -----------------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# -----------------------------------------------------
# Helm provider wired to same cluster
# -----------------------------------------------------
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

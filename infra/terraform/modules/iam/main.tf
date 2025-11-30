##############################################
# Operator Role
# WHY: Dedicated role for cluster administration (kubectl, Terraform).
# HOW: Trusts your IAM user (nancy-devops) to assume it.
##############################################

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_operator" {
  name = "EKSOperatorRole"

  # Trust policy: only your IAM user can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_id}:user/nancy-devops"
      }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

# Attach AWS-managed EKS admin policies
resource "aws_iam_role_policy_attachment" "eks_operator_cluster" {
  role       = aws_iam_role.eks_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_operator_service" {
  role       = aws_iam_role.eks_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Attach your custom operator policy (fine-grained permissions)
resource "aws_iam_policy" "operator_policy" {
  name   = "ProjectGPU-E2E-Operator"
  policy = file("${path.root}/policies/operator.json")
}

resource "aws_iam_role_policy_attachment" "operator_attach" {
  role       = aws_iam_role.eks_operator.name
  policy_arn = aws_iam_policy.operator_policy.arn
}


# -----------------------------
# ALB Controller Role (IRSA)
# -----------------------------
resource "aws_iam_role" "alb_controller" {
  name = "ALBControllerIRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.eks_oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.eks_oidc_provider_sub}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_policy" "alb_policy" {
  name   = "AWSLoadBalancerControllerPolicy"
  policy = file("${path.root}/policies/alb.json")
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_policy.arn
}

# -----------------------------
# EKS Controller Role (ARN)
# -----------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = file("${path.root}/policies/eks.json")

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# -----------------------------
# EKS GPU node group (ARN)
# -----------------------------
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = file("${path.root}/policies/node-trust-policy.json")

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

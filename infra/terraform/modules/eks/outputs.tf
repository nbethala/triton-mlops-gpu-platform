output "cluster_name" {
  value = aws_eks_cluster.gpu_e2e.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.gpu_e2e.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.gpu_e2e.certificate_authority[0].data
}

#output "oidc_provider_arn" {
#  value = aws_eks_cluster.gpu_e2e.identity[0].oidc[0].issuer
#}

output "oidc_provider_sub" {
  value = "system:serviceaccount:kube-system:cluster-autoscaler"
}

#output "oidc_provider_arn" {
#  value = aws_iam_openid_connect_provider.eks.arn
#}

output "oidc_provider_url" {
  value = aws_eks_cluster.gpu_e2e.identity[0].oidc[0].issuer
}


#!/bin/bash
# cleanup-iam.sh
# Detach policies, delete IAM roles/policies, and verify cleanup

set -euo pipefail

# Roles to delete
ROLES=(
  "EKSOperatorRole"
  "ALBControllerIRSA"
  "GitHubActionsECRRole"
  "eks-gpu-nodegroup-role"
  "ClusterAutoscalerIRSA"
  "triton-mlops-github-actions-oidc-role"
)

# Policies to delete
POLICIES=(
  "ProjectGPU-E2E-Operator"
  "ALBControllerIAMPolicy"
  "ProjectGPU-ClusterAutoscaler"
  "triton-mlops-github-eks-ci-cd-policy"
)

echo "=== Starting IAM cleanup ==="

for ROLE in "${ROLES[@]}"; do
  echo "Processing role: $ROLE"
  ATTACHED=$(aws iam list-attached-role-policies --role-name "$ROLE" --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null || true)
  for POLICY_ARN in $ATTACHED; do
    echo " Detaching $POLICY_ARN"
    aws iam detach-role-policy --role-name "$ROLE" --policy-arn "$POLICY_ARN" || true
  done

  INLINE=$(aws iam list-role-policies --role-name "$ROLE" --query "PolicyNames[]" --output text 2>/dev/null || true)
  for POLICY_NAME in $INLINE; do
    echo " Deleting inline policy $POLICY_NAME"
    aws iam delete-role-policy --role-name "$ROLE" --policy-name "$POLICY_NAME" || true
  done

  echo " Deleting role $ROLE"
  aws iam delete-role --role-name "$ROLE" || true
done

for POLICY in "${POLICIES[@]}"; do
  echo "Processing policy: $POLICY"
  POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY'].Arn" --output text)
  if [ -n "$POLICY_ARN" ]; then
    echo " Deleting policy $POLICY"
    aws iam delete-policy --policy-arn "$POLICY_ARN" || true
  fi
done

echo "=== Verification ==="
echo "Remaining roles with 'EKS','ALB','gpu','ClusterAutoscaler','github':"
aws iam list-roles --query "Roles[?contains(RoleName, 'EKS') || contains(RoleName, 'ALB') || contains(RoleName, 'gpu') || contains(RoleName, 'ClusterAutoscaler') || contains(RoleName, 'github')].RoleName" --output text

echo "Remaining policies with 'GPU','ALB','ClusterAutoscaler','github':"
aws iam list-policies --scope Local --query "Policies[?contains(PolicyName, 'GPU') || contains(PolicyName, 'ALB') || contains(PolicyName, 'ClusterAutoscaler') || contains(PolicyName, 'github')].PolicyName" --output text

echo "=== Cleanup complete ==="

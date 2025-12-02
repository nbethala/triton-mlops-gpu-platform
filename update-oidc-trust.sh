#!/bin/bash

# ------------------------------
# CONFIGURATION
# ------------------------------
ROLE_NAME="<YOUR_ROLE_NAME>"  # replace with your IAM role name
OIDC_PROVIDER_ARN="arn:aws:iam::478253497479:oidc-provider/token.actions.githubusercontent.com"
REPO_SUBJECT="repo:nbethala/triton-pipeline:ref:refs/heads/main"

# ------------------------------
# RENDER TEMPLATE
# ------------------------------
envsubst < ci.json.tpl > ci.json

# ------------------------------
# UPDATE IAM ROLE TRUST POLICY
# ------------------------------
aws iam update-assume-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-document file://ci.json

echo "✅ IAM role trust policy updated successfully for OIDC!"

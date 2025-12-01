This chart deploys Triton with:
 - initContainer to sync models from S3 into an emptyDir
 - ability to use IRSA via serviceAccount.annotations
 - nodeSelector + tolerations for GPU scheduling

Set `serviceAccount.annotations.eks.amazonaws.com/role-arn` to the IRSA role for S3 access.


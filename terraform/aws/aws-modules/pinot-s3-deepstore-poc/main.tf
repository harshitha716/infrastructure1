resource "aws_s3_bucket" "pinot_deepstore_poc" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "pinot_deepstore_poc" {
  bucket = aws_s3_bucket.pinot_deepstore_poc.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "pinot_s3_policy_poc" {
  name        = "PinotS3DeepStorePolicyPoc"
  path        = "/"
  description = "IAM policy for Pinot to access S3 POC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                   = true
  role_name                     = "pinot-s3-access-role_poc"
  provider_url                  = var.eks_oidc_provider_url
  role_policy_arns              = [aws_iam_policy.pinot_s3_policy_poc.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
}

# resource "kubernetes_service_account" "pinot_s3_access" {
#   metadata {
#     name      = var.k8s_service_account_name
#     namespace = var.k8s_namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.iam_assumable_role_with_oidc.iam_role_arn
#     }
#   }
# }
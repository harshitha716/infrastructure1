resource "aws_s3_bucket" "selenium_grid" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "selenium_grid" {
  bucket = aws_s3_bucket.selenium_grid.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}
resource "aws_iam_policy" "selenium_grid_s3_policy" {
  name        = "seleniumgridS3DeepStorePolicy"
  path        = "/"
  description = "IAM policy for selenium-grid to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action   = "s3:ListAllMyBuckets"  # Add this permission to list all buckets
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      },
      {
        Effect = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

data "aws_iam_policy_document" "selenium_grid_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.eks_oidc_provider_url, "https://", "")}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "selenium_grid_s3_access_role" {
  name               = "selenium-grid-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.selenium_grid_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "selenium_grid_s3_policy_attachment" {
  policy_arn = aws_iam_policy.selenium_grid_s3_policy.arn
  role       = aws_iam_role.selenium_grid_s3_access_role.name
}
# -------------------------------------------
#  S3 Bucket & IAM Policy & Role for Pantheon
# --------------------------------------------
resource "aws_s3_bucket" "s3" {
  bucket        = "${var.s3["bucket_name"]}"
  force_destroy = var.s3["force_destroy"]

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.s3.tags, {
    Name = "${var.s3["bucket_name"]}"
  })
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status = var.s3["versioning"] ? "Enabled" : "Suspended"
  }
}



resource "aws_iam_policy" "s3_irsa_policy" {
  name        = "S3BucketIRSAAccessPolicy"
  description = "IAM policy for IRSA to access the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.s3.arn,
          "${aws_s3_bucket.s3.arn}/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.pantheon_k8s_namespace}:${var.pantheon_s3_service_account}"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.eks_oidc_provider_url, "https://", "")}"]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "s3_irsa_role" {
  name               = "${var.pantheon_role_name}"#"zamp-prd-uae-pantheon-irsa-access-role"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_irsa_policy_attachment" {
  policy_arn = aws_iam_policy.s3_irsa_policy.arn
  role       = aws_iam_role.s3_irsa_role.name
}



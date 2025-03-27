# Fetch AWS Account ID dynamically
data "aws_caller_identity" "current" {}

# -------------------------------
#  S3 Bucket for Loki Logs
# -------------------------------
resource "aws_s3_bucket" "loki_logs" {
  bucket         = var.s3_bucket_name
  force_destroy  = true
}

resource "aws_s3_bucket_public_access_block" "loki_logs" {
  bucket = aws_s3_bucket.loki_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning (optional)
resource "aws_s3_bucket_versioning" "loki_logs_versioning" {
  bucket = aws_s3_bucket.loki_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption (optional)
resource "aws_s3_bucket_server_side_encryption_configuration" "loki_logs_encryption" {
  bucket = aws_s3_bucket.loki_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------
#  IAM Policy for Loki
# -------------------------------
resource "aws_iam_policy" "loki_s3_policy" {
  name        = "LokiS3AccessPolicy"
  description = "IAM policy for Loki to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      },
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

# -------------------------------
#  IAM Policy Document for IRSA (OIDC)
# -------------------------------
data "aws_iam_policy_document" "loki_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.loki_service_account}"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.eks_oidc_provider_url, "https://", "")}"]
      type        = "Federated"
    }
  }
}

# -------------------------------
#  IAM Role for Loki
# -------------------------------
resource "aws_iam_role" "loki_s3_access_role" {
  name               = "loki-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.loki_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "loki_s3_policy_attachment" {
  policy_arn = aws_iam_policy.loki_s3_policy.arn
  role       = aws_iam_role.loki_s3_access_role.name
}

# -------------------------------
#  IAM Policy & Role for Prometheus
# -------------------------------
resource "aws_iam_policy" "prometheus_policy" {
  name        = "PrometheusEKSAccessPolicy"
  description = "IAM policy for Prometheus to access EKS metrics and logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:ListClusters", "eks:DescribeCluster"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:GetLogEvents"]
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "prometheus_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.prometheus_service_account}"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.eks_oidc_provider_url, "https://", "")}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "prometheus_access_role" {
  name               = "prometheus-eks-access-role"
  assume_role_policy = data.aws_iam_policy_document.prometheus_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "prometheus_policy_attachment" {
  policy_arn = aws_iam_policy.prometheus_policy.arn
  role       = aws_iam_role.prometheus_access_role.name
}


# Fluent Bit IAM Policy
resource "aws_iam_policy" "fluent_bit_policy" {
  name        = "FluentBitPolicy"
  description = "IAM policy for Fluent Bit"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Fluent Bit IAM Role
data "aws_iam_policy_document" "fluent_bit_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.fluent_bit_service_account}"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.eks_oidc_provider_url}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "fluent_bit_role" {
  name               = "fluent-bit-eks-role"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "fluent_bit_policy_attachment" {
  policy_arn = aws_iam_policy.fluent_bit_policy.arn
  role       = aws_iam_role.fluent_bit_role.name
}

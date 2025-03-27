# -------------------------------
#  IAM Policy & Role for Prometheus
# -------------------------------
resource "aws_iam_policy" "prometheus_policy" { 
  name        = "PrometheusEKSAccessPolicys"
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

data "aws_caller_identity" "current" {}

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
  name               = "${var.prometheus_role_name}"
  assume_role_policy = data.aws_iam_policy_document.prometheus_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "prometheus_policy_attachment" {
  policy_arn = aws_iam_policy.prometheus_policy.arn
  role       = aws_iam_role.prometheus_access_role.name
}





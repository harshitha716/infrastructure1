#OIDC Provider for GitHub
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "9e99a48a96f3c7e1f2339cfef76f70972f1daed7"  # GitHub's OIDC certificate thumbprint
  ]
}

#IAM Role with Trust Policy for Multiple Repositories
resource "aws_iam_role" "github_oidc_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = flatten([
      for repo in var.github_repos : [
        {
          Effect    = "Allow"
          Principal = {
            Federated = aws_iam_openid_connect_provider.github_oidc.arn
          }
          Action    = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            }
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:${repo}:ref:refs/heads/*"
            }
          }
        }
      ]
    ])
  })
}

#Attach IAM policy to the role
resource "aws_iam_role_policy_attachment" "github_oidc_policy_attachment" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/${var.policy_name}"
}

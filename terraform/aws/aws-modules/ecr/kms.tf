resource "aws_kms_key" "ecr" {
  count = anytrue([for repo in var.ecr_repositories : lookup(repo, "enable_encryption", false)]) ? 1 : 0
  description = "KMS key for encrypting ECR repositories"
}

resource "aws_kms_alias" "ecr" {
  count = length(aws_kms_key.ecr) > 0 ? 1 : 0
  name  = var.kms_key_alias
  target_key_id = aws_kms_key.ecr[0].id
}

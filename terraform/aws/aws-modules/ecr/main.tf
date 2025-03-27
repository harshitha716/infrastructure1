resource "aws_ecr_repository" "ecr-repositories" {
  for_each = { for repo in var.ecr_repositories : repo.name => repo }

  name = each.value.name

  image_scanning_configuration {
    scan_on_push = each.value.enable_scanning
  }

  image_tag_mutability = each.value.tag_mutability

  encryption_configuration {
    encryption_type = each.value.enable_encryption ? "KMS" : "AES256"
    kms_key         = each.value.enable_encryption && length(aws_kms_key.ecr) > 0 ? aws_kms_key.ecr[0].arn : null
  }

  tags = each.value.tags
}


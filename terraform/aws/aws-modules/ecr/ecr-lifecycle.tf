resource "aws_ecr_lifecycle_policy" "ecr-lifecycle" {
  for_each = { for repo in var.ecr_repositories : repo.name => repo if repo.enable_lifecycle }
  
  repository = each.value.name
  policy     = jsonencode({
    rules = [{
      rulePriority = var.lifecycle_policy.rulePriority
      description  = var.lifecycle_policy.description
      selection = {
        tagStatus   = var.lifecycle_policy.tagStatus
        countType   = var.lifecycle_policy.countType
        countNumber = var.lifecycle_policy.countNumber
      }
      action = {
        type = var.lifecycle_policy.actionType
      }
    }]
  })
}

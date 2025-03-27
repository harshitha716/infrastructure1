variable "ecr_repositories" {
}

variable "kms_key_alias" {
  description = "Alias for the KMS key used to encrypt ECR repositories"
  type        = string
  default     = "alias/ecr-kms-key"
}

variable "lifecycle_policy" {
  description = "Lifecycle policy settings for ECR repositories"
  type = object({
    rulePriority = number
    description  = string
    tagStatus    = string
    countType    = string
    countNumber  = number
    actionType   = string
  })
}

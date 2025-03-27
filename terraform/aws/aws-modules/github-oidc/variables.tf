variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "policy_name" {
  description = "The ARN of the IAM policy to attach to the role"
  type        = string
}

variable "github_repos" {
  description = "List of GitHub repositories to allow for access"
  type        = list(string)
}

variable "aws_account_id" {
  description = "The AWS account ID where resources will be created"
  type        = string
}

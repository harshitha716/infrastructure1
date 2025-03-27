output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.pinot_deepstore.id
}

output "iam_role_arn" {
  value       = aws_iam_role.pinot_s3_access_role.arn
  description = "The ARN of the IAM role created for Pinot S3 access"
}

# output "k8s_service_account_name" {
#   description = "Name of the Kubernetes service account created"
#   value       = kubernetes_service_account.pinot_s3_access.metadata[0].name
# }

# output "pinot_s3_role_arn" {
#   value       = module.pinot_s3_role.iam_role_arn
#   description = "ARN of the IAM role for Pinot S3 full access"
# }

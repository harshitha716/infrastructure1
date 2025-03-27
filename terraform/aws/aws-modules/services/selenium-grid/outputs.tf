output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.selenium_grid.id
}

output "iam_role_arn" {
  value       = aws_iam_role.selenium_grid_s3_access_role.arn
  description = "The ARN of the IAM role created for selenium-grid S3 access"
}

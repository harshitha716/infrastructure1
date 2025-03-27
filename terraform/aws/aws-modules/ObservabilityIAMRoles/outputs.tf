output "loki_role_arn" {
  description = "IAM Role ARN for Loki"
  value       = aws_iam_role.loki_s3_access_role.arn
}

output "prometheus_role_arn" {
  description = "IAM Role ARN for Prometheus"
  value       = aws_iam_role.prometheus_access_role.arn
}

output "s3_bucket_name" {
  description = "S3 bucket name for Loki logs"
  value       = aws_s3_bucket.loki_logs.id
}

output "fluent_bit_role_arn" {
  description = "IAM Role ARN for Fluent Bit"
  value       = aws_iam_role.fluent_bit_role.arn
  
}
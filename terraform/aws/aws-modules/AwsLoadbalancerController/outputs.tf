# output "service_account_name" {
#   description = "Name of the Kubernetes service account for the AWS Load Balancer Controller"
#   value       = kubernetes_service_account.lb_controller_sa.metadata[0].name
# }

# output "iam_role_arn" {
#   description = "ARN of the IAM role for the AWS Load Balancer Controller"
#   value       = module.lb_controller_role.iam_role_arn
# }
variable "s3_bucket_name" {
  description = "Name of the S3 bucket to be used as Pinot deep store"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "The OpenID Connect provider URL for the EKS cluster (without the 'https://' prefix)"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where Pinot is deployed"
  type        = string
  default     = "pinot"
}

variable "k8s_service_account_name" {
  description = "Name of the Kubernetes service account for Pinot S3 access"
  type        = string
  default     = "pinot-s3-access"
}


# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
# }

# variable "oidc_provider_arn" {
#   description = "ARN of the OIDC provider associated with the EKS cluster"
#   type        = string
# }

# variable "s3_bucket_name" {
#   description = "Name of the S3 bucket for Pinot deep store"
#   type        = string
# }

# variable "pinot_namespace" {
#   description = "Kubernetes namespace where Pinot is deployed"
#   type        = string
#   default     = "pinot"
# }

# variable "pinot_service_account" {
#   description = "Name of the Kubernetes service account for Pinot"
#   type        = string
#   default     = "pinot"
# }

# variable "tags" {
#   description = "A map of tags to add to all resources"
#   type        = map(string)
#   default     = {}
# }
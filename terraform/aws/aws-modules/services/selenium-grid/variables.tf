variable "s3_bucket_name" {
  description = "Name of the S3 bucket to be used as selenium-grid deep store"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "The OpenID Connect provider URL for the EKS cluster (without the 'https://' prefix)"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where selenium-grid is deployed"
  type        = string
  default     = "selenium-grid"
}

variable "k8s_service_account_name" {
  description = "Name of the Kubernetes service account for selenium-grid S3 access"
  type        = string
  default     = "selenium-grid-selenium-serviceaccount"
}
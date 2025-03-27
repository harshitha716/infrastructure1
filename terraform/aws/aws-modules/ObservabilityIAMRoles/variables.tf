variable "s3_bucket_name" {
  description = "S3 bucket name for Loki logs storage"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "OIDC provider URL for EKS IRSA"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for observability components"
  type        = string
}

variable "prometheus_service_account" {
  description = "Kubernetes Service Account for Prometheus"
  type        = string
}

variable "loki_service_account" {
  description = "Kubernetes Service Account for Loki"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "fluent_bit_service_account" {
  description = "Kubernetes Service Account for Fluent Bit"
  type        = string
  
}
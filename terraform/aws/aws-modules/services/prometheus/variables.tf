variable "eks_oidc_provider_url" {
  description = "OIDC Url for observability components"
  type = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for observability components"  
  type = string
}

variable "prometheus_service_account" {
  description = "Service Account  for observability prometheus"  
  type = string
}


variable "prometheus_role_name" {
  type = string
}

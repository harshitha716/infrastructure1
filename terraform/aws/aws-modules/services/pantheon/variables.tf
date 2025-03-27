variable "s3" {
  description = "Configuration for S3 bucket"
  type = object({
    bucket_name   = string
    acl           = string
    force_destroy = bool
    versioning    = bool
    tags          = map(string)
  })
}


variable "eks_oidc_provider_url" {
  type = string
}


variable "pantheon_k8s_namespace" {
  type = string
}

variable "pantheon_s3_service_account" {
  
}

variable "pantheon_role_name" {
  type = string
}

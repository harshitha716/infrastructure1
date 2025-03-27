variable "service_accounts" {
  description = "List of k8s Service accounts"
}

variable "project_prefix" {
  description = "project_prefix"
}

variable "project_id" {
  description = "project id"
}


variable "buckets" {
  description = "environment specific buckets"
  default = []
}

variable "cors_origins" {
  description = "origins to be whitelisted for cors"
  default = []
}


variable "region" {
  description = "gcp region to create gcp resources"
}

variable "buckets-regional" {
  description = "environment specific buckets"
  default = []
}
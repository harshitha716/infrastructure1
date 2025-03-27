variable "service_accounts" {
  description = "List of k8s Service accounts"
}

variable "project_prefix" {
  description = "project_prefix"
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "gcp region to create gcp resources"
}
variable "region_code" {
  type = map(any)
  default = {
    asia-south1     = "mb" # Mumbai
    asia-south2     = "dl" # Delhi
    asia-southeast1 = "sg"
    europe-west1    = "eu" #belgium

  }
}
variable "region" {
  description = "region of operation"
}

variable "project_id" {
    description = "gcp project id"
}
variable "project" {
    description = "project key"
}
variable "environment" {
    description = "environment name"
}

variable "region_code" {
  type = map
  default = {
    asia-south1      = "mb" # Mumbai
    asia-south2      = "dl" # Delhi
    asia-southeast1  = "sg"
  }
} 

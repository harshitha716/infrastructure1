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
    europe-west1    = "eu" #belgium
    us-west1        = "us" #oregon

  }
} 

variable "spanner_instance_name" {
  description = "spanner instance name"
}

variable "environment_eu" {
  description = "environment name"
}
variable "region_eu" {
  description = "region name"
}
variable "default_zone_eu" {
  description = "default zone"
}

variable "spanner_instance_name_eu" {
  description = "spanner instance name"
}
# variable "cloudfunctions" {
#   type = list
# }

variable "environment_usa" {
  description = "environment name"
}
variable "region_usa" {
  description = "region name"
}
variable "default_zone_usa" {
  description = "default zone"
}

variable "spanner_instance_name_usa" {
  description = "spanner instance name"
}
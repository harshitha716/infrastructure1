variable "region_code" {
  type = map
  default = {
    asia-south1      = "mb" # Mumbai
    asia-south2      = "dl" # Delhi
    asia-southeast1  = "sg"
  }
} 

variable project_id {
  description = "google project id"
}
variable project {
  description = "project name"
}
variable environment {
  description = "environment name"
}
variable region {
  description = "region name"
}
variable default_zone {
  description = "default_zone"
}


locals {
  user_labels = {
    env = "dev"
  }
}
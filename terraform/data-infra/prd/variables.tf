variable "region_code" {
  type = map
  default = {
    asia-south1      = "mb" # Mumbai
    asia-south2      = "dl" # Delhi
    asia-southeast1  = "sg"
    europe-west1     = "eu" #belgium
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

variable enable_streaming_job{
  description = "flat to enable streaming job"
  default=false
}

variable "enable_redash" {
  description = "flag to enable redash module"
  default = false
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
variable "target_region" {
  description = "The target region for resources"
  default     = "europe-west1"  # Change this to "asia-southeast1" if needed
}
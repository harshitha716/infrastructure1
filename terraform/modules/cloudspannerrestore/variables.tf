variable "project_id" {
    description = "gcp project id"
}

variable "uniform_bucket_level_access" {
    default = true 
}

variable "local_output_path" {
  type    = string
  default = "restorezip"
}

variable "project_prefix" {
} 

variable "region" {
}

variable "log_bucket" {
  default = null
}

variable "log_object_prefix" {
  default = null
}
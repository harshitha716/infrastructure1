# variable project_id {
#   description = "project_id"
# }
variable "proj_prefix" {
  description = "project_prefix"
}
variable "region" {
  description = "region"
}
variable "processing_units" {
  description = "processing_units"
}
variable "environment" {
  description = "environment name"
}
variable "name_suffix" {
  description = "Suffix to append to the display name and name of the Cloud Spanner instance."
  type        = string
  default     = ""
}

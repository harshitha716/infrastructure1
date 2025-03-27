variable "name_tag" {}

# variable "cdn_domain" {}

variable "proj_prefix" {}


variable "serve_sdk" {
  default = true
  description = "flag to enable sdk serving bucket and cdn"
}
variable "static_hosting_domain" {
  description = "website hostname"
}
variable "sdk_domain" {
  description = "sdk hostname"
  default = ""
}
variable "test_sdk" {
  default = false
  description = "flag to create gcs hosting for develop branch"
}
variable "log_bucket" {
  default = null
}

variable "log_object_prefix" {
  default = null
}
variable proj_prefix {
  description = "proj_prefix"
}
# variable private_source_ranges {
#   description = "private_source_ranges"
# }
variable office_ip_list {
  description = "office_ip_list"
  default = []
}
variable network {
  description = "network"
}

variable "enable_logging" {
  default = false
  description = "To enable logging"
}
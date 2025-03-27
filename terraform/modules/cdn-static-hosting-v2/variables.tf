variable "name_tag" {}

# variable "cdn_domain" {}

variable "proj_prefix" {}

variable enable_https_redirect {
  type        = bool
  default     = true
}

variable "static_hosting_domain" {
  description = "website hostname"
}

variable "only_vpn_access" {
  description = "VPN access"
  default = true
}

variable "vpn_connector_ip" {
  description = "VPN connector IP"
  default = ""
}
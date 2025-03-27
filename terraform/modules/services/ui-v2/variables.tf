variable "name_tag" {}

# variable "cdn_domain" {}

variable "proj_prefix" {}

variable "static_hosting_domain" {
  type = list(string)
  description = "website hostname"
}

variable "only_vpn_access"{
  description = "VPN access"
  default = false
}

variable "vpn_connector_ip"{
  description = "VPN connector IP"
  default = ""
}
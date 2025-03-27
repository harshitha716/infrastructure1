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
# variable vpc_public_subnet_cidr {
#   description = "vpc_public_subnet_cidr"
# }
# variable vpc_private_subnet_cidr {
#   description = "vpc_private_subnet_cidr"
# }
# variable vpc_private_proxy_subnet_cidr {
#   description = "vpc_private_proxy_subnet_cidr"
# }
variable firewall_office_ip_list {
  description = "firewall_office_ip_list"
}
variable gke_master_ipv4_cidr_block {
  description = "gke_master_ipv4_cidr_block"
}

variable cloudspanner_processing_units {
  description = "cloudspanner_node_count"
}
variable "open_vpn_token" {
  default= "test"
}

#CloudSQL
variable "tier_hcp" {
  type = string
  default = "db-custom-1-4096"
}
variable "tier" {
  type = string
  default = "db-custom-1-4096"
}

variable "disk_size_gb" {
  type = number
  default = "20"
}

variable "postgress_pass" {
  default = "password"
}

variable "postgress_pass_recon" {
  default = "password"
}

variable "postgress_pass_hcp" {
  default = "password"
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}
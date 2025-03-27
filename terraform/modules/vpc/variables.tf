variable "region_code" {
  type = map
  default = {
    asia-south1      = "mb" # Mumbai
    asia-south2      = "dl" # Delhi

  }
}
#var.region_code[var.region]

variable proj_prefix {
  description = "A name prefix used in resource names to ensure uniqueness across a project."
}
variable region {
  description = "The region for subnetworks in the network."
}

variable public_subnet_cidr {
  description = "The IP address range of the Subnetwork in CIDR notation."
}
variable private_subnet_cidr {
  description = "The IP address range of the Subnetwork in CIDR notation."
}
variable private_proxy_subnet_cidr {
  description = "The IP address range of the Subnetwork in CIDR notation."
}
variable public_subnet_secondary_cidrs {
  description = "public_subnet_secondary_cidrs"
  default = {}
}
variable private_subnet_secondary_cidrs {
  description = "private_subnet_secondary_cidrs"
  default = {}
}
variable private_proxy_subnet_secondary_cidrs {
  description = "private_proxy_subnet_secondary_cidrs"
  default = {}
}
variable nat_ip_count {
  description = "No of IP that needs to be attached to the Cloud NAT"
  default = 1
}

variable "log_config" {
  description = "The logging options for the subnetwork flow logs. Setting this value to `null` will disable them. See https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html for more information and examples."
  
  # type = object({
  #   aggregation_interval = string
  #   flow_sampling        = number
  #   metadata             = string
  # })

  default = null
}

variable "auto_create_subnetworks" {
  description = "flag for auto subnet creation"
  default = true
}
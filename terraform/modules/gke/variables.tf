variable "proj_prefix" {
  type = string
  description = "The name of the project."
}

variable "region" {
  type = string
  description = "The name of the region where the cluster need to be created."
}

variable "location_zonal_type" {
  type = string
  description = "Whether the cluster type is zonal"
  default = false
}
variable "vpn_ips" {
  description = "Vpn ips "
}
variable "zone" {
  type = string
  description = "The name of the region zone where the cluster need to be created. (for zonal cluster type)"
  default = null
}

variable "environment" {
  type = string
  description = "The name of the envionment"
}

variable "vpc" {
  type        = string
  description = "The name of the vpc for the cluster."
}

variable "subnetwork" {
  description = "The name of the subnetwork for the cluster."
  default = null
}

variable "network_tags" {
  description = "The list of network tags that needs to be added to the node."
}

variable "node_pool_machine_type" {
  type        = string
  description = "Type of the node compute engines."
  default     = "e2-medium"
}

variable "node_pool_root_disk_size" {
  type        = number
  description = "Node disk size (Gb)"
  default     = 30
}

variable "node_pool_network_tags" {
  description = "Network tags that need to be added to the Node"
  default     = ["private"]
}

variable "node_pool_min_node_count" {
  type        = number
  description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
}

variable "node_pool_max_node_count" {
  type        = number
  description = "Maximum number of nodes in the NodePool. Must be >= min_node_count."
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation where the control plane needs to reside, /26 required"
}

variable "channel_type" {
  description = "cluster channel type."
  default = "UNSPECIFIED"
}

variable "k8s_version" {
  default = "1.22.8-gke.201"

}

variable "ingress_static_ip" {
  description = "static Ingress ip" 
  default = false
}

variable "name_suffix" {
  default = ""
}

# variable "nat_ips" {
#   description = "List of NAT IP addresses for GKE cluster (optional)"
#   type        = list(string)
#   default     = null
#   # Add any other necessary attributes
# }

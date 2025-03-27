variable "proj_prefix" {
  type = string
  description = "The name of the project."
}

variable "cluster_name" {
  type = string
  description = "The name of cluster."
}

variable "cluster_location" {
  type = string
  description = "The cluster location"
}
variable "labels" {
  
}
variable "taints" {
  default = {}
}
variable "environment" {
  type = string
  description = "The name of the envionment"
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

# variable "node_pool_min_node_count" {
#   type        = number
#   description = "Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count."
# }

# variable "node_pool_max_node_count" {
#   type        = number
#   description = "Maximum number of nodes in the NodePool. Must be >= min_node_count."
# }

variable "preemptible_node" {
  description = "Enable Preempitble node type"
  type        = bool
  default     = false
}

variable "google_service_account_email" {
  description = "Email of the service account."
}

variable "node_pool_name" {
  description = "node_pool_name."
}

variable "node_count" {
  default = null
  
}

variable "autoscaling" {
  default = {
    enabled = false
    max_node_count = 1
    min_node_count = 1
  }
}
variable "node_locations" {
  default = null
}

# variable "initial_node_count" {
#   default = null
# }


variable "shielded_instance_config" {
  default = {}
}
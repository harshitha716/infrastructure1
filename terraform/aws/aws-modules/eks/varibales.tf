variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for EKS"
  type        = list(string)
}
# variable "openvpn_cidrs" {
#   description = "List of CIDRs for OpenVPN access to EKS API"
#   type        = list(string)
# }

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "worker_nodes_group_list" {
  description = "List of worker node groups"
  type = list(object({
    name             = string
    instance_types   = list(string)
    maximum_capacity = number
    minimum_capacity = number
    capacity_type    = string
    tags             = map(string)
  }))
}

variable "worker_nodes_group_list_public" {
  description = "List of worker node groups"
  type = list(object({
    name             = string
    instance_types   = list(string)
    maximum_capacity = number
    minimum_capacity = number
    capacity_type    = string
    tags             = map(string)
  }))
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
  
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 100
}


variable "core_node_group" {
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  })
}

variable "controller_node_group" {
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  })
  
}

variable "broker_node_group" {
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  })
  
}

variable "zookeeper_node_group" {
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  })
  
}

variable "server_node_group" {
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  })
  
}

variable "minion_node_group" {
  
  type = object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tags           = map(string)
  })
}

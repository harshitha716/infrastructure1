variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpcs" {
  type = list
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}
variable "public_subnets" {
  type = list
}
variable "private_subnets" {
  type = list
}
variable "private_subnet_route_tables" {
  type = list
}
variable "public_subnet_route_tables" {
  type = list
}

variable "nat_gateways" {
  type = list
}
variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 100
}

# variable "allowed_cidr" {
#   description = "The CIDR block to allow SSH access from"
#   type        = string
# }

# variable "worker_nodes_group_list" {
#   description = "List of worker node groups"
#   type = list(object({
#     name             = string
#     instance_types   = list(string)
#     maximum_capacity = number
#     minimum_capacity = number
#     capacity_type    = string
#     tags             = map(string)
#   }))
# }

# variable "worker_nodes_group_list_public" {
#   description = "List of worker node groups"
#   type = list(object({
#     name             = string
#     instance_types   = list(string)
#     maximum_capacity = number
#     minimum_capacity = number
#     capacity_type    = string
#     tags             = map(string)
#   }))
# }


# variable "core_node_group" {
#   type = object({
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#     instance_types = list(string)
#     capacity_type  = string
#     disk_size      = number
#     labels         = map(string)
#     taints         = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))
#     tags           = map(string)
#   })
# }

# variable "controller_node_group" {
#   type = object({
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#     instance_types = list(string)
#     capacity_type  = string
#     disk_size      = number
#     labels         = map(string)
#     taints         = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))
#     tags           = map(string)
#   })
  
# }

# variable "broker_node_group" {
#   type = object({
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#     instance_types = list(string)
#     capacity_type  = string
#     disk_size      = number
#     labels         = map(string)
#     taints         = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))
#     tags           = map(string)
#   })
  
# }

# variable "zookeeper_node_group" {
#   type = object({
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#     instance_types = list(string)
#     capacity_type  = string
#     disk_size      = number
#     labels         = map(string)
#     taints         = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))
#     tags           = map(string)
#   })
  
# }

# variable "server_node_group" {
#   type = object({
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#     instance_types = list(string)
#     capacity_type  = string
#     disk_size      = number
#     labels         = map(string)
#     taints         = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))
#     tags           = map(string)
#   })
  
# }

# variable "minion_node_group" {
  
#   type = object({
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#     instance_types = list(string)
#     capacity_type  = string
#     disk_size      = number
#     labels         = map(string)
#     taints         = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))
#     tags           = map(string)
#   })
# }

variable "databricks_vpc_peering_connection" {
  description = "Databricks VPC peering connection details"
  type = object({
    name       = string
    vpc_cidr   = string
  })
}

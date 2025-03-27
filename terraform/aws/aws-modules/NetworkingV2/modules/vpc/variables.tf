variable "environment" {
  type = string
}

variable "vpcs" {
  type = list
}

variable "region" {
  type = string
}

variable "vpc_flow_logs" {
  type = object({
    log_destination_type = string
    traffic_type         = string
    log_group_name       = string
    log_retention_days   = number
    environment          = string
  })
}
  

#   variable "eks_nodes_sg_id" {
#   type = string
# }
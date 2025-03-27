
variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "nat_gateways" {
  type = list
}

variable "private_subnets" {
  type = list
}

variable "public_subnets" {
  type = list
}

variable "private_subnet_route_tables" {
  type = list
}

variable "public_subnet_route_tables" {
  type = list
}


variable "databricks_vpc_peering_connection" {
  description = "Databricks VPC peering connection details"
  type = object({
    name       = string
    vpc_cidr   = string
  })
}
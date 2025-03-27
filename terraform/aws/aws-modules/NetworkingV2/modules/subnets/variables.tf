
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


variable "cidr_block_ip1"{
  type = string
  default = "100.80.0.0/12"
}

variable "cidr_block_ip2"{
  type = string
  default = "100.96.0.0/11"
}

variable "network_interface_id" {
  type = string
  default = "eni-05edd0853e29fc786"
}

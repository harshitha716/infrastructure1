variable "proj_prefix" {
    description = "project prefix"
}
variable "auto_create_subnets" {
    description = "auto create subnets"
    default = true
}
variable "region" {
    description = "region for router"
}

variable "nat_ip_count" {
  description = "number of nat instances"
  default = 1
}
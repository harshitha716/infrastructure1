variable "network" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "connectors" {
  type = map(any)
}

variable "instance_size" {
  type = string
  default = "n1-standard-1"
}

variable "project_prefix" {
  
}
variable "zone" {
  description = "The zone where the instance will be created."
  default     = "asia-southeast1-a" # Provide a default value for other regions
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the bastion host will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the bastion host can be placed"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the bastion host"
  type        = string
}

variable "allowed_cidr" {
  description = "The CIDR block to allow SSH access from"
  type        = string
}
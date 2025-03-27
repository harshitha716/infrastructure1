
variable "vpcs" {
  type = list(any)
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}
variable "public_subnets" {
  type = list(any)
}
variable "private_subnets" {
  type = list(any)
}
variable "private_subnet_route_tables" {
  type = list(any)
}
variable "public_subnet_route_tables" {
  type = list(any)
}

variable "nat_gateways" {
  type = list(any)
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


variable "ecr_repositories" {
  description = "List of ECR repositories with tags"
  type = list(object({
    name              = string
    tags              = map(string)
    enable_lifecycle  = bool
    enable_scanning   = bool
    tag_mutability    = string
    enable_encryption = bool
  }))
}

variable "kms_key_alias" {}

variable "lifecycle_policy" {
  description = "Lifecycle policy for ECR repositories"
  type = object({
    rulePriority = number
    description  = string
    tagStatus    = string
    countType    = string
    countNumber  = number
    actionType   = string
  })
}


variable "vpc_flow_logs" {

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
    eks_ami_id       = string
  }))
}

variable "service" {
  type = map(string)
}

variable "s3" {
  description = "Configuration for S3 bucket"
  type = object({
    bucket_name   = string
    acl           = string
    force_destroy = bool
    versioning    = bool
    tags          = map(string)
  })
}

variable "rds" {
  type = map(object({
    name                                  = string
    env                                   = string
    db_identifier                         = string
    db_name                               = string
    engine                                = string
    engine_version                        = string
    allocated_storage                     = number
    instance_class                        = string
    db_username                           = string
    db_password                           = string
    parameter_group_name                  = string
    parameter_group_family                = string
    backup_retention_period               = number
    port                                  = number
    storage_type                          = string
    auto_minor_version_upgrade            = bool
    multi_az                              = bool
    publicly_accessible                   = bool
    skip_final_snapshot                   = bool
    performance_insights_enabled          = bool
    performance_insights_retention_period = number
    copy_tags_to_snapshot                 = bool
    storage_encrypted                     = bool
    deletion_protection                   = bool
  }))
}

variable "secrets" {
  description = "List of secrets to be created with descriptions"
  type        = list(object({
    name        = string
    description = string
    tags        = map(string)
  }))
}

variable "tags" {
  
}


variable "rds" {
  type = map(object({
    name = string
    env  = string
    db_identifier = string
    db_name       = string
    engine        = string
    engine_version = string
    allocated_storage = number
    instance_class    = string
    db_username       = string
    db_password       = string
    parameter_group_name = string
    parameter_group_family= string
    backup_retention_period = number
    port              = number
    storage_type      = string
    auto_minor_version_upgrade = bool
    multi_az               = bool
    publicly_accessible    = bool
    skip_final_snapshot    = bool
    performance_insights_enabled = bool
    performance_insights_retention_period = number
    copy_tags_to_snapshot = bool
    storage_encrypted = bool
    deletion_protection = bool
  }))
}


variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_ids" {
  
}

variable "db_sg_name" {
  type = string
}

variable "subnet_group_name" {
  type = string
}

variable "kms_key_name" {
  type = string
}

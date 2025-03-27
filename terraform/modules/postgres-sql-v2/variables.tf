variable "name" {
  type = string
}


variable "region" {
  type = string
}

variable "tier" {
  type = string
}

variable "disk_size_gb" {
  type = number

default = "20"
}

variable "vpc_name" {
  type = string
}

variable "env" {
  type = string
}

variable "project_id" {
  type = string
}

variable "postgres_username" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "enable_backups" {
  default = true
}

variable "point_in_time_recovery_enabled" {
  default = true
}

variable "deletion_protection" {
  default = true
}

variable "database_flags" {
  type    = list(any)
  default = []
}

variable "query_insights_enabled" {
  default = false
}

variable "postgres_version" {
  type = string
}

variable "user_labels" {
  type    = map(string)
  default = {}
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "public_ipv4_connectivity" {
  type = object({
    enabled             = bool
    authorized_networks = map(string)
  })
  default = {
    authorized_networks = {}
    enabled             = false
  }
}

variable "project" {
  type        = string
  description = "metadata for cost attribution"

}



variable "project_prefix" {
    description = "project prefix"
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "uniform_bucket_level_access" {
  type = bool
}

variable "schedule" {
  type    = string
}

variable "time_zone" {
  type    = string
  default = "Asia/Calcutta"
}


variable "local_output_path" {
  type    = string
  default = "backupzip"
}

variable "database_ids" {
  type = set(string)
}

variable "spanner_instance_id" {
  type = string
}


variable "project_prefix" {
}

variable "backup_retention_period" {
  description = "backup_retention_period for db "
}


variable "webhook_url" {
}

variable "log_bucket" {
  default = null
}

variable "log_object_prefix" {
  default = null
}

variable "kms_rotation_duration" {
  default = "7776000s"
  description = "kms key rotation duration default: 90days"
}
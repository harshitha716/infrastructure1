variable "project_prefix" {}
# variable "project" {}

variable "service_account" {
  description = "service account name"
}

variable "project_id" {
  description = "project id"
}


#############

variable "pubsub_topics" {}

variable "region" {
  
}

variable "kms_rotation_duration" {
  default = "7776000s"
  description = "kms key rotation duration default: 90days"
}

variable "kms_key_name" {
  default = ""
  description = "kms key name"
}


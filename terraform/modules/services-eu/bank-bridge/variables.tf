variable "service_accounts" {
  description = "List of k8s Service accounts"
}

variable "project_prefix" {
  description = "project_prefix"
}

variable "project_id" {
  description = "project id"
}

variable "pubsub_topics" {
  type = list(object({
    name = string
    dlq_enabled = bool
    ack_deadline_seconds = optional(number,600)
    enable_message_ordering = optional(bool,true)
    enable_exactly_once_delivery = optional(bool,true)
    subscriptions = list(string)
  }))
}

variable "buckets" {
  description = "environment specific buckets"
  default = []
}

variable "cors_origins" {
  description = "origins to be whitelisted for cors"
  default = []
}


variable "region" {
  description = "gcp region to create gcp resources"
}
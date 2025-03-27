variable "project_prefix" {
  description = "project_prefix"
}

variable "region" {
  description = "region"
}

variable "spanner_instance_name" {
  description = "spanner instance name"
}

variable "spanner_db_name" {
  description = "db name"
}

variable "project_id" {
  description = "project id"
}

variable "roles" {
  description = "list of roles to be attached"
}

variable "service_accounts" {
  description = "service account details"
  default = []
}


# variable "cloud_tasks" {
#   default = []
# }

variable "cloud_tasks" {
  type = list(object({
    name    = string
    region = string
    max_attempts  = optional(number,-1) # max attempts
    max_retry_duration = optional(string,"15s")
    max_backoff = optional(string,"3600s")
    min_backoff = optional(string,"0.100s")
    max_doublings = optional(number,16)
    max_concurrent_dispatches = optional(number,1000)
    max_dispatches_per_second = optional(number,500)
    sampling_ratio = optional(number,0.9)
  }))
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
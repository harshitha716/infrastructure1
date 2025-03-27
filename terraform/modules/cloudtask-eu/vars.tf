variable "name" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "max_concurrent_dispatches" {
  type    = string
  default = "3"
}

variable "max_dispatches_per_second" {
  type    = string
  default = "2"
}

variable "max_attempts" {
  type    = string
  default = "5"
}

variable "max_retry_duration" {
  type    = string
  default = "4s"
}

variable "max_backoff" {
  type    = string
  default = "3s"
}

variable "min_backoff" {
  type    = string
  default = "2s"
}

variable "max_doublings" {
  type    = string
  default = "1"
}

variable "sampling_ratio" {
  type    = string
  default = "0.9"
}
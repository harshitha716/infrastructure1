# General Configuration
variable "name" {
  description = "Name of the Composer environment"
  type        = string
}

variable "region" {
  description = "Region where the Composer environment will be created"
  type        = string
}

variable "service_account" {
  description = "Service account to use for the Composer environment"
  type        = string
}

variable "image_version" {
  description = "Image version for Composer"
  type        = string
}

# Network Configuration
variable "enable_private_environment" {
  description = "Enable private IP for Composer environment"
  type        = bool
  default     = true
}

variable "network" {
  description = "Network ID for Composer environment"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork ID for Composer environment"
  type        = string
}

variable "enable_web_server_plugins" {
  description = "Enable web server plugins"
  type        = bool
  default     = true
}

variable "resilience_mode" {
  description = "Resilience mode for Composer environment"
  type        = string
  default     = "STANDARD_RESILIENCE"
}

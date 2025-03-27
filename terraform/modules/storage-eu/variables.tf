
# variable "cdn_domain" {}

variable "proj_prefix" {}

variable "storage" {
  type = list(object({
    name                  = string
    public                = optional(bool,false)
    versioning            = optional(bool,true)
    log_bucket            = optional(string,"")
    log_object_prefix     = optional(string,"")
    backend_bucket_enable = optional(bool,false)
    cdn_enable            = optional(bool,false)
    index_document        = optional(string,"index.html")
    error_document        = optional(string,"index.html")
    force_destroy         = optional(bool,false)
    enable_cors           = optional(bool,false)
    cors = optional(object({
      origin          = list(string)
      method          = list(string)
      response_header = list(string)
      max_age_seconds = number
    }))
  }))
}

variable "location" {
  description = "location of gcs"
  default     = "EU"
}



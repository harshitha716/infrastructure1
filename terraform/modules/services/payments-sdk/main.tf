data "google_project" "project" {
}
module "storage" {
  source      = "../../../modules/storage"
  proj_prefix = var.proj_prefix
  storage = local.env == "prd" ? [{
    name                  = "merchant-ui"
    backend_bucket_enable = true
    cdn_enable            = true
    public                = true
    enable_cors = true
    cors = {
          "origin"          = ["*"]
          "method"          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
          "response_header" = ["*"]
          "max_age_seconds" = 3600
        }
    log_bucket            = "${var.proj_prefix}-gcs-logging"
    },
    {
      name                  = "payments-sdk"
      backend_bucket_enable = true
      cdn_enable            = true
      enable_cors = true
      cors = {
            "origin"          = ["*"]
            "method"          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
            "response_header" = ["*"]
            "max_age_seconds" = 3600
          }
      public                = true
      log_bucket            = "${var.proj_prefix}-gcs-logging"
    },
    {
      name       = "payments-sdk-test"
      public     = true
      log_bucket = "${var.proj_prefix}-gcs-logging"
    }
    ] : [{
      name                  = "merchant-ui"
      backend_bucket_enable = true
      cdn_enable            = true
      enable_cors = true
      cors = {
            "origin"          = ["*"]
            "method"          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
            "response_header" = ["*"]
            "max_age_seconds" = 3600
          }
      public                = true
      log_bucket            = "${var.proj_prefix}-gcs-logging"
    },
    {
      name                  = "payments-sdk"
      backend_bucket_enable = true
      cdn_enable            = true
      public                = true
      enable_cors = true
      cors = {
          "origin"          = ["*"]
          "method"          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
          "response_header" = ["*"]
          "max_age_seconds" = 3600
      }
      log_bucket            = "${var.proj_prefix}-gcs-logging"
    },
    {
      name   = "payments-sdk-test"
      public = true
      log_bucket            = "${var.proj_prefix}-gcs-logging"
    }
  ]
}


module "cdn_lb" {
  depends_on = [
    module.storage
  ]
  source        = "../../../modules/cdn-loadbalancer"
  proj_prefix   = var.proj_prefix
  name_tag      = var.name_tag
  project_id    = data.google_project.project.project_id
  static_domain = var.static_domain
}

resource "google_secret_manager_secret" "secret_manager_secret" {
  for_each  = toset(var.secrets)
  secret_id = "${var.proj_prefix}-${each.value}"
  replication {
    auto {}
  }
}


locals {
  env = split("-", var.proj_prefix)[1]
}

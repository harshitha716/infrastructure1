data "google_project" "project" {
}

#secret manager secrets for tms-dashboard repo

resource "google_secret_manager_secret" "tms_dashboard" {
  secret_id = "${var.project_prefix}-tms-dashboard-env"
  replication {
    automatic = true
  }
}

module "storage" {
  source      = "../../../modules/storage-eu"
  proj_prefix = var.project_prefix
  storage = [{
    name                  = "tms-assets"
    backend_bucket_enable = true
    cdn_enable            = true
    public                = true
    enable_cors           = true
    cors = {
      "origin"          = ["*"]
      "method"          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      "response_header" = ["*"]
      "max_age_seconds" = 3600
    }
    log_bucket = "${var.project_prefix}-gcs-logging"
    }
  ]
}

module "cdn_lb" {
  depends_on = [
    module.storage
  ]
  source        = "../../../modules/cdn-loadbalancer"
  proj_prefix   = var.project_prefix
  name_tag      = "tms-assets"
  project_id    = data.google_project.project.project_id
  static_domain = var.static_domain
}
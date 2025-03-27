data "google_project" "project" {
}

#secret manager secrets for herm-dashboard repo

resource "google_secret_manager_secret" "herm_dashboard" {
  secret_id = "${var.project_prefix}-herm-dashboard-env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "herm_dashboard-cypress" {
  secret_id = "${var.project_prefix}-herm-dashboard-env-cypress"
  replication {
    auto {}
  }
}

module "storage" {
  source      = "../../../modules/storage"
  proj_prefix = var.project_prefix
  storage = [{
    name                  = "herm-assets"
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
  name_tag      = "herm-assets"
  project_id    = data.google_project.project.project_id
  static_domain = var.static_domain
}
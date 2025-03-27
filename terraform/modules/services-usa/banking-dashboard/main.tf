data "google_project" "project" {
}

#secret manager secrets for banking-dashboard repo

resource "google_secret_manager_secret" "banking_dashboard" {
  secret_id = "${var.project_prefix}-banking-dashboard-env"
  replication {
    automatic = true
  }
}

# resource "google_secret_manager_secret" "banking_dashboard_sirius" {
#   count     = local.sirius_env == "dev" || local.sirius_env == "prd" ? 1 : 0
#   secret_id = "${var.project_prefix}-sirius-banking-dashboard-env"
#   replication {
#     automatic = true
#   }
# }

module "storage" {
  source      = "../../../modules/storage-eu"
  proj_prefix = var.project_prefix
  storage = [{
    name                  = "assets"
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
  name_tag      = "assets"
  project_id    = data.google_project.project.project_id
  static_domain = var.static_domain
}

locals {
  sirius_env = split("-", var.project_prefix)[1]
}

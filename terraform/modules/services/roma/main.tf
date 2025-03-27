
#secret manager secrets for roma repo

resource "google_secret_manager_secret" "roma_env" {
  secret_id = "${var.project_prefix}-roma-env"
  replication {
    auto {}
  }
}

# Creating bucket for roma-static files
resource "google_storage_bucket" "roma_static" {
  name                        = "${var.project_prefix}-roma-static-files"
  location                    = "ASIA"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  logging {
    log_bucket = "${var.project_prefix}-gcs-logging"
  }
}

# Making bucket public
resource "google_storage_bucket_iam_binding" "roma_static" {
  bucket = google_storage_bucket.roma_static.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
}

locals {
  env = split("-", var.project_prefix)[1]
}

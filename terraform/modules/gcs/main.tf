resource "google_storage_bucket" "helm_repo" {
  name          = "${var.proj_prefix}-helm-repository"
  location      = var.location
  versioning {
    enabled = true
  }
  logging {
    log_bucket = google_storage_bucket.gcs_logging_bucket.name
  }
}

resource "google_storage_bucket" "backups_bucket" {
  name                        = "${var.proj_prefix}-backups"
  location                    = var.location
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  logging {
    log_bucket = google_storage_bucket.gcs_logging_bucket.name
  }
}

resource "google_storage_bucket" "gcs_logging_bucket" {
  name                        = "${var.proj_prefix}-gcs-logging"
  location                    = var.location
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  logging {
    log_bucket = "${var.proj_prefix}-gcs-logging"
  }
}

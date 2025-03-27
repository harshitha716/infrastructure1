module "cdn" {
  source                = "../../../modules/cdn-static-hosting"
  proj_prefix           = var.proj_prefix
  name_tag              = var.name_tag
  static_hosting_domain = var.static_hosting_domain
  sdk_domain            = var.sdk_domain
  serve_sdk             = var.serve_sdk
  log_bucket            = var.log_bucket
  log_object_prefix     = var.log_object_prefix
}
resource "google_secret_manager_secret" "secret_manager_secret" {
  secret_id = "${var.proj_prefix}-${var.name_tag}-env"
  replication {
    auto {}
  }
}

# Creating bucket for test-sdk
resource "google_storage_bucket" "test-sdk" {
  count                       = var.test_sdk ? 1 : 0
  name                        = "${var.proj_prefix}-${var.name_tag}-test"
  location                    = "ASIA"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

# Making bucket public
resource "google_storage_bucket_iam_binding" "test-sdk" {
  count  = var.test_sdk ? 1 : 0
  bucket = google_storage_bucket.test-sdk[0].name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
}
resource "google_secret_manager_secret" "secret_manager_secret_test" {
  count     = var.serve_sdk ? (var.test_sdk ? 1 : 0) : 0
  secret_id = "${var.proj_prefix}-${var.name_tag}-test-env"
  replication {
    auto {}
  }
}

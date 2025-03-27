
# Creating bucket for website
resource "google_storage_bucket" "main" {
  for_each                    = {for index, x in var.storage : x.name => x} 
  name                        = "${var.proj_prefix}-${each.value.name}"
  location                    = var.location
  uniform_bucket_level_access = true
  versioning {
    enabled = each.value.versioning
  }
  website {
    main_page_suffix = "${each.value.index_document}"
    not_found_page   = "${each.value.error_document}"
  }
  dynamic "cors"{
    for_each = each.value.enable_cors ? [1] : []
    content {
      origin          = each.value.cors.origin
      method          = each.value.cors.method
      response_header = each.value.cors.response_header
      max_age_seconds = each.value.cors.max_age_seconds
  }
  }
  dynamic logging {
    for_each = each.value.log_bucket == null ? [] : [each.value.log_bucket]
    content {
      log_bucket = each.value.log_bucket
      log_object_prefix = each.value.log_object_prefix
    }
  }
}

# Making bucket public
resource "google_storage_bucket_iam_binding" "main" {
  for_each = {for x in var.storage : x.name => x if x.public}
  bucket = "${var.proj_prefix}-${each.value.name}"
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
  depends_on = [
    google_compute_backend_bucket.main
  ]
}

# Backend - Bucket target
resource "google_compute_backend_bucket" "main" {
  for_each = {for x in var.storage : x.name => x if x.backend_bucket_enable}
  name        = "${var.proj_prefix}-${each.value.name}"
  description = "Backend bucket for serving static content through CDN"
  bucket_name = "${var.proj_prefix}-${each.value.name}"
  enable_cdn  = each.value.cdn_enable
  depends_on = [
    google_storage_bucket.main
  ]
}

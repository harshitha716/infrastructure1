data "google_project" "project" {
}
resource "google_storage_bucket" "cloudfunction_bucket" {
  name     = "${var.project_prefix}-cloudfunction_bucket"
  location = "ASIA"
}

resource "google_cloudfunctions2_function" "cloudfunctions" {
for_each = { for index, config in var.cloudfunctions : index => config }
  name         = lookup(each.value, "name")
  description  =  lookup(each.value, "description")
  location     = var.region
  build_config{
    runtime      = lookup(each.value, "runtime")
    entry_point  = lookup(each.value, "entry_point")
    source {
      storage_source {
        bucket = google_storage_bucket.cloudfunction_bucket.name
        object = lookup(each.value, "object")
      }
    }
  }
  service_config{
    max_instance_count                = 2
    min_instance_count                = 1
    available_memory                  = lookup(each.value, "available_memory_mb")
    timeout_seconds                   = 60
    max_instance_request_concurrency  = lookup(each.value, "max_instance_request_concurrency")
    available_cpu                     = "0.333"
    ingress_settings                  = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision    = true
    service_account_email             = var.service_account_email
  }
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  for_each = google_cloudfunctions2_function.cloudfunctions

  project        = each.value.project
  location       = each.value.location
  cloud_function = each.value.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.service_account_email}"
}

resource "google_cloud_run_service_iam_member" "cloud_run_invoker" {
  for_each = google_cloudfunctions2_function.cloudfunctions

  project  = each.value.project
  location = each.value.location
  service  = each.value.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.service_account_email}"
}

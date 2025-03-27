//Service Accounts for cloudfunction 

resource "google_service_account" "restore_sa" {
  account_id   = "${var.project_prefix}-spannerrestore-sa"
  display_name = "Spanner Restore Function Service Account"
}

# resource "google_project_iam_member" "restore_sa_spanner_iam" {
#   project = var.project_id
#   role    = "roles/spanner.restoreAdmin"
#   member  = "serviceAccount:${google_service_account.restore_sa.email}"
# }

module "restore_spanner_role" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "SpannerRestore"
  title                = "Spanner Restore"
  description          = "Spanner restore role for spanner restoration cloud function"
  base_roles           = ["roles/spanner.restoreAdmin"]
  members              = ["serviceAccount:${google_service_account.restore_sa.email}"]
  permissions          = []
  excluded_permissions = ["resourcemanager.projects.list"]
}
//Cloud Function

resource "google_storage_bucket" "bucket_spannerrestore_source" {
  name                        = "${var.project_prefix}-restore-function"
  storage_class               = "REGIONAL"
  location                    = var.region
  force_destroy               = "true"
  uniform_bucket_level_access = var.uniform_bucket_level_access
  versioning {
    enabled = true
  }
  dynamic "logging" {
    for_each = var.log_bucket == null ? [] : [var.log_bucket]
    content {
      log_bucket        = var.log_bucket
      log_object_prefix = var.log_object_prefix
    }
  }
}

data "archive_file" "local_backup_source" {
  type        = "zip"
  source_dir  = abspath("${path.module}/restore")
  output_path = "${var.local_output_path}/restore.zip"
}

resource "google_storage_bucket_object" "gcs_functions_restore_source" {
  name   = "restore.${data.archive_file.local_backup_source.output_md5}.zip"
  bucket = google_storage_bucket.bucket_spannerrestore_source.name
  source = data.archive_file.local_backup_source.output_path
  lifecycle {
    ignore_changes = all
  }
}

resource "google_cloudfunctions_function" "spanner_restore_function" {
  name        = "${var.project_prefix}-spannerrestore"
  description = "Spanner Restore Function"
  runtime     = "go119"
  timeout     = 120
  # https_trigger_security_level = "SECURE_ALWAYS"
  ingress_settings      = "ALLOW_INTERNAL_ONLY"
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.bucket_spannerrestore_source.name
  source_archive_object = google_storage_bucket_object.gcs_functions_restore_source.name
  trigger_http          = true
  entry_point           = "Httptrigger"
  service_account_email = google_service_account.restore_sa.email
}

// service account for job to trigger function
resource "google_service_account" "k8sjob_sa" {
  account_id   = "${var.project_prefix}-functiontrigger-sa"
  display_name = "Trigger Restore Function Service Account"
}

resource "google_project_iam_member" "k8sjob_sa_trigger_iam" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.k8sjob_sa.email}"
}



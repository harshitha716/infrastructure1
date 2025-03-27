data "google_project" "project" {
}

resource "google_service_account" "airbyte_app" {
  account_id   = "${var.project_prefix}-airbyte"
  display_name = "airbyte service account"
}

resource "google_service_account_iam_binding" "account_iam_airbyte" {
  service_account_id = google_service_account.airbyte_app.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}

resource  "google_project_iam_member"  "airbyte_app_bq_data_editor"  { 
  role     = "roles/bigquery.dataEditor" 
  member   = "serviceAccount:${google_service_account.airbyte_app.email}" 
  project = local.project
 }

resource  "google_project_iam_member"  "airbyte_app_bq_user"  { 
  role     = "roles/bigquery.user" 
  member   = "serviceAccount:${google_service_account.airbyte_app.email}" 
  project = local.project
 }

resource  "google_storage_bucket_iam_member"  "airbyte_app_storage_admin_log"  { 
  bucket = google_storage_bucket.airbyte_log.name
   role    = "roles/storage.admin" 
  member = "serviceAccount:${google_service_account.airbyte_app.email}" 
}

# storage bucket for airbyte logs
resource  "google_storage_bucket"  "airbyte_log"  { 
  name      = "${var.project_prefix}-airbyte-log" 
  location = "ASIA"

  uniform_bucket_level_access = true
}

# Bind GSA to KSA 
resource  "google_service_account_iam_member"  "airbyte_app_k8s_iam_default"  { 
  service_account_id = google_service_account.airbyte_app.name
   role                = "roles/iam.workloadIdentityUser" 
  member              = "serviceAccount:${local.project}.svc.id.goog[airbyte/default]" 
}

resource  "google_service_account_iam_member"  "airbyte_app_k8s_iam_airbyte_admin"  { 
  service_account_id = google_service_account.airbyte_app.name
   role                = "roles/iam.workloadIdentityUser" 
  member              = "serviceAccount:${local.project}.svc.id.goog[airbyte/airbyte-admin]" 
}

resource "google_secret_manager_secret" "airbyte_secrets_env" {
  secret_id = "${var.project_prefix}-airbyte-secrets-env"
  replication {
    auto {}
  }
}

# module "airbyte_role" {
#   source               = "../../custom-iam-role"
#   target_level         = "project"
#   target_id            = var.project_id
#   role_id              = "AirbyteRole"
#   title                = "Role for airbyte service"
#   description          = "Custom role for airbyte action"
#   base_roles           = local.roles
#   members              = ["serviceAccount:${google_service_account.airbyte_app.email}"]
#   permissions          = ["container.clusters.getCredentials", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
#   excluded_permissions = ["resourcemanager.projects.list"]
# }




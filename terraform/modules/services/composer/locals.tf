locals {
  members_map  = { for x in var.service_accounts : x.k8s_service_account_name => x }
  members_list = [for k, v in local.members_map : "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${v.k8s_service_account_namespace}/${k}]"]
  roles        = ["roles/storage.objectAdmin", "roles/iam.serviceAccountTokenCreator","roles/spanner.viewer","roles/spanner.databaseUser", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor"]
    buckets-regional = concat([{
    name        = "composer-files"
    enable_cors = true
    log_bucket  = "${var.project_prefix}-gcs-logging"
    cors = {
      origin          = var.cors_origins
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
    }
  ], var.buckets-regional)
}

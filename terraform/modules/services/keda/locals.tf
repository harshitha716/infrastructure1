locals {
  members_map  = { for x in var.service_accounts : x.k8s_service_account_name => x }
  members_list = [for k, v in local.members_map : "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${v.k8s_service_account_namespace}/${k}]"]
  roles        = ["roles/storage.objectAdmin", "roles/iam.serviceAccountTokenCreator","roles/spanner.viewer","roles/spanner.databaseUser","roles/monitoring.viewer"]
}

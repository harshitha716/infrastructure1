data "google_project" "project" {
}

resource "google_service_account" "service_account_keda" {
  account_id   = "${var.project_prefix}-keda"
  display_name = "keda platform service account"
}

resource "google_service_account_iam_binding" "account_iam_keda" {
  service_account_id = google_service_account.service_account_keda.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "keda_secrets_env" {
  secret_id = "${var.project_prefix}-keda-secrets-env"
  replication {
    auto {}
  }
}

module "keda_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "kedaRole"
  title                = "Role for keda service"
  description          = "Custom role for keda action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_keda.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings","datacatalog.categories.fineGrainedGet"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


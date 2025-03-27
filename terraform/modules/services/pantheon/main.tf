data "google_project" "project" {
}

resource "google_service_account" "service_account_pantheon" {
  account_id   = "${var.project_prefix}-pantheon"
  display_name = "pantheon platform service account"
}

resource "google_service_account_iam_binding" "account_iam_pantheon" {
  service_account_id = google_service_account.service_account_pantheon.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "pantheon_secrets_env" {
  secret_id = "${var.project_prefix}-pantheon-secrets-env"
  replication {
    auto {}
  }
}


module "pantheon_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "PantheonRole"
  title                = "Role for pantheon service"
  description          = "Custom role for pantheon action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_pantheon.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "storage-regional" {
  source      = "../../storage-regional"
  proj_prefix = var.project_prefix
  storage     = local.buckets-regional
}
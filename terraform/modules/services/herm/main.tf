data "google_project" "project" {
}

resource "google_service_account" "service_account_herm" {
  account_id   = "${var.project_prefix}-herm"
  display_name = "herm service account"
}

resource "google_service_account_iam_binding" "account_iam_herm" {
  service_account_id = google_service_account.service_account_herm.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "herm_secrets_env" {
  secret_id = "${var.project_prefix}-herm-secrets-env"
  replication {
    auto {}
  }
}

module "herm_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "HermRole"
  title                = "Role for herm service"
  description          = "Custom role for herm action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_herm.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

# module "pubsub" {
#   source          = "../../pubsub"
#   region          = var.region
#   project_prefix  = var.project_prefix
#   project_id      = var.project_id
#   service_account = google_service_account.service_account_herm.email
#   pubsub_topics   = var.pubsub_topics
#   kms_key_name      = "${var.project_prefix}-pubsub"
# }

module "storage-regional" {
  source      = "../../storage-regional"
  proj_prefix = var.project_prefix
  storage     = local.buckets-regional
}
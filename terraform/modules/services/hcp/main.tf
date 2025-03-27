data "google_project" "project" {
}

resource "google_service_account" "service_account_hcp" {
  account_id   = "${var.project_prefix}-hcp"
  display_name = "hcp service account"
}

resource "google_service_account_iam_binding" "account_iam_hcp" {
  service_account_id = google_service_account.service_account_hcp.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "hcp_secrets_env" {
  secret_id = "${var.project_prefix}-hcp-secrets-env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "hcp_dashboard_env" {
  secret_id = "${var.project_prefix}-hcp-dashboard-env"
  replication {
    auto {}
  }
}


module "hcp_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "HcpRole"
  title                = "Role for hcp service"
  description          = "Custom role for workflow action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_hcp.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

# module "pubsub" {
#   source          = "../../pubsub"
#   region          = var.region
#   project_prefix  = var.project_prefix
#   project_id      = var.project_id
#   service_account = google_service_account.service_account_hcp.email
#   pubsub_topics   = var.pubsub_topics
#   kms_key_name      = "${var.project_prefix}-pubsub"
# }

module "storage-regional" {
  source      = "../../storage-regional"
  proj_prefix = var.project_prefix
  storage     = local.buckets-regional
}
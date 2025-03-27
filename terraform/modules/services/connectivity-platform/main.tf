data "google_project" "project" {
}

resource "google_service_account" "service_account_connectivity" {
  account_id   = "${var.project_prefix}-connectivity"
  display_name = "connectivity platform service account"
}

resource "google_service_account_iam_binding" "account_iam_connectivity" {
  service_account_id = google_service_account.service_account_connectivity.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "connectivity_secrets_env" {
  secret_id = "${var.project_prefix}-connectivity-secrets-env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "connectivity_client_key" {
  secret_id = "${var.project_prefix}-connectivity-client-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "connectivity_client_secret" {
  secret_id = "${var.project_prefix}-connectivity-client-secret"
  replication {
    auto {}
  }
}


module "connectivity_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "connectivityRole"
  title                = "Role for connectivity service"
  description          = "Custom role for connectivity action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_connectivity.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "storage-regional" {
  source      = "../../storage-regional"
  proj_prefix = var.project_prefix
  storage     = local.buckets-regional
}
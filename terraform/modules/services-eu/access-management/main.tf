data "google_project" "project" {
}

resource "google_service_account" "service_account_access_management" {
  account_id   = "${var.project_prefix}-access-management"
  display_name = "access management service account"
}

resource "google_service_account_iam_binding" "account_iam_access_management" {
  service_account_id = google_service_account.service_account_access_management.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "access_management_secrets_env" {
  secret_id = "${var.project_prefix}-access-management-secrets-env"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "access_management_configs_env" {
  secret_id = "${var.project_prefix}-access-management-configs-env"
  replication {
    automatic = true
  }
}

module "access_management_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "AccessManagementRoleV2"
  title                = "Role for access_management service"
  description          = "Custom role for access management action"
  base_roles           = local.roles
  members              = ["serviceAccount:${var.project_prefix}-access-management@${var.project_id}.iam.gserviceaccount.com"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


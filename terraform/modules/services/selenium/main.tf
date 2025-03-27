data "google_project" "project" {
}

resource "google_service_account" "service_account_selenium" {
  account_id   = "${var.project_prefix}-selenium"
  display_name = "selenium platform service account"
}

resource "google_service_account_iam_binding" "account_iam_selenium" {
  service_account_id = google_service_account.service_account_selenium.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



module "selenium_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "seleniumRole"
  title                = "Role for selenium service"
  description          = "Custom role for selenium action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_selenium.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
}


# module "storage-regional" {
#   source      = "../../storage-regional"
#   proj_prefix = var.project_prefix
#   storage     = local.buckets-regional
# }
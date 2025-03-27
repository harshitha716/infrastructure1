data "google_project" "project" {
}

resource "google_service_account" "service_account_alchemist" {
  account_id   = "${var.project_prefix}-alchemist"
  display_name = "alchemist service account"
}

resource "google_service_account_iam_binding" "account_iam_alchemist" {
  service_account_id = google_service_account.service_account_alchemist.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "alchemist_secrets_env" {
  secret_id = "${var.project_prefix}-alchemist-secrets-env"
  replication {
    auto {}
  }
}

module "alchemist_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "AlchemistRole"
  title                = "Role for alchemist service"
  description          = "Custom role for alchemist action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_alchemist.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "pubsub" {
  source          = "../../pubsub"
  region          = var.region
  project_prefix  = var.project_prefix
  project_id      = var.project_id
  service_account = google_service_account.service_account_alchemist.email
  pubsub_topics   = var.pubsub_topics
  kms_key_name      = "${var.project_prefix}-pubsub"
}

module "storage" {
  source      = "../../storage"
  proj_prefix = var.project_prefix
  storage     = local.buckets
}
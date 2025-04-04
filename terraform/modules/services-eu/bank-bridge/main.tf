data "google_project" "project" {
}

resource "google_service_account" "service_account_bank_bridge" {
  account_id   = "${var.project_prefix}-bank-bridge"
  display_name = "bank bridge service account"
}

resource "google_service_account_iam_binding" "account_iam_bank_bridge" {
  service_account_id = google_service_account.service_account_bank_bridge.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "bank_bridge_secrets_env" {
  secret_id = "${var.project_prefix}-bank-bridge-secrets-env"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "bank_bridge_configs_env" {
  secret_id = "${var.project_prefix}-bank-bridge-configs-env"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "zamp_leantech-certs" {
  secret_id = "${var.project_prefix}-zamp_leantech-certs"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "zamp_leantech-private-key" {
  secret_id = "${var.project_prefix}-zamp_leantech-private-key"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "zamp_leantech-key-chain" {
  secret_id = "${var.project_prefix}-zamp_leantech-key-chain"
  replication {
    automatic = true
  }
}

module "bank_bridge_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "BankBridgeRoleV2"
  title                = "Role for bank_bridge service"
  description          = "Custom role for bank bridge action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_bank_bridge.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "pubsub" {
  source          = "../../pubsub-eu"
  region          = var.region
  project_prefix  = var.project_prefix
  project_id      = var.project_id
  service_account = google_service_account.service_account_bank_bridge.email
  pubsub_topics   = var.pubsub_topics
  kms_key_name      = "${var.project_prefix}-pubsub"
}

module "storage" {
  source      = "../../storage-eu"
  proj_prefix = var.project_prefix
  storage     = local.buckets
}
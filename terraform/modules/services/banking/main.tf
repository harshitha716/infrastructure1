

data "google_project" "project" {
}

resource "google_spanner_database" "database" {
  instance            = var.spanner_instance_name
  name                = var.spanner_db_name
  deletion_protection = true
}

resource "google_service_account" "service_account" {
  account_id   = "${var.project_prefix}-cs-banking"
  display_name = "${var.spanner_instance_name} banking service account"
}

resource "google_service_account_iam_binding" "account_iam" {
  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}
resource "google_project_iam_member" "sa_role" {
  for_each = toset(var.roles)
  project  = data.google_project.project.id
  role     = each.key
  member   = "serviceAccount:${google_service_account.service_account.email}"
}

#service account for banking

resource "google_service_account" "service_account_banking" {
  account_id   = "${var.project_prefix}-banking"
  display_name = "banking service account"
}

resource "google_service_account_iam_binding" "account_iam_banking" {
  service_account_id = google_service_account.service_account_banking.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}
resource "google_project_iam_member" "sa_role_banking" {
  for_each = toset(var.roles)
  project  = data.google_project.project.id
  role     = each.key
  member   = "serviceAccount:${google_service_account.service_account_banking.email}"
}

#secret manager secrets for banking repo

resource "google_secret_manager_secret" "banking_env" {
  secret_id = "${var.project_prefix}-banking-env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "web3communicator_env" {
  secret_id = "${var.project_prefix}-web3communicator-env"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret" "web3communicator_config" {
  secret_id = "${var.project_prefix}-web3communicator-config"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "fireblocks_key" {
  secret_id = "${var.project_prefix}-fireblocks-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "nium_cards_pgp" {
  secret_id = "${var.project_prefix}-nium-cards-pgp"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "zamp_cards_pgp" {
  secret_id = "${var.project_prefix}-zamp-cards-pgp"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "banking-okta-configs" {
  secret_id = "${var.project_prefix}-banking-okta-configs"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "cloudfunctions_env" {
  secret_id = "${var.project_prefix}-cloudfunctions_env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "resource-credential-public-key" {
  secret_id = "${var.project_prefix}-resource-credential-public-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "resource-credential-private-key" {
  secret_id = "${var.project_prefix}-resource-credential-private-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "fireblocks_uae_key" {
  secret_id = "${var.project_prefix}-fireblocks-uae-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "red_envelope_api_secret_key" {
  secret_id = "${var.project_prefix}-red-envelope-api-secret-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "roma_paymonade_otp_public_key" {
  secret_id = "${var.project_prefix}-roma-paymonade-otp-public-key"
  replication {
    auto {}
  }
}
module "cloudtask" {
  for_each                  = { for index, x in var.cloud_tasks : x.name => x }
  source                    = "../../cloudtask"
  name                      = each.value.name
  region                    = each.value.region
  max_attempts              = each.value.max_attempts
  max_retry_duration        = each.value.max_retry_duration
  max_backoff               = each.value.max_backoff
  min_backoff               = each.value.min_backoff
  max_doublings             = each.value.max_doublings
  max_concurrent_dispatches = each.value.max_concurrent_dispatches
  max_dispatches_per_second = each.value.max_dispatches_per_second
  sampling_ratio            = each.value.sampling_ratio
}

module "storage" {
  source      = "../../storage"
  proj_prefix = var.project_prefix
  storage     = local.buckets
}

module "storage-regional" {
  source      = "../../storage-regional"
  proj_prefix = var.project_prefix
  storage     = local.buckets-regional
}

resource "google_storage_bucket_iam_member" "member" {
  for_each = { for bucket in local.buckets : bucket.name => bucket }
  bucket   = "${var.project_prefix}-${each.value.name}"
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.service_account_banking.email}"
}

resource "google_storage_bucket_iam_member" "member-2" {
  for_each = { for bucket in local.buckets-regional : bucket.name => bucket }
  bucket   = "${var.project_prefix}-${each.value.name}"
  role     = "roles/storage.admin"
  member   = "serviceAccount:${google_service_account.service_account_banking.email}"
}

module "pubsub" {
  source          = "../../pubsub"
  region          = var.region
  project_prefix  = var.project_prefix
  project_id      = var.project_id
  service_account = google_service_account.service_account_banking.email
  pubsub_topics   = var.pubsub_topics
}

resource "google_kms_key_ring" "dataflow_analytics" {
  count    = local.env == "prd" ? 1 : 0
  name     = "${var.project_prefix}-dataflow-analytics"
  location = var.region
}

resource "google_kms_crypto_key" "dataflow_analytics" {
  count           = local.env == "prd" ? 1 : 0
  name            = "${var.project_prefix}-dataflow-analytics"
  key_ring        = google_kms_key_ring.dataflow_analytics[0].id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}


module "dataflow_spanner_job_role" {
  count                = local.env == "prd" ? 1 : 0
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "DataflowSpannerCSVExport"
  title                = "Dataflow Spanner CSV Export"
  description          = "Role for k8s cronjob to trigger dataflow job and export to storage bucket"
  base_roles           = ["roles/dataflow.admin", "roles/storage.admin"]
  members              = ["${google_service_account.service_account_banking.member}", "${google_service_account.service_account.member}"]
  permissions          = []
  excluded_permissions = ["resourcemanager.projects.list"]
} 

# module "cloudfunctions" {
#   source                 = "../../cloudfunctions"
#   location               = var.location
#   region                 = var.region
#   project_prefix         = var.project_prefix
#   project_id             = var.project_id
#   service_account_email  = google_service_account.service_account_banking.email
#   cloudfunctions         = var.cloudfunctions
# }
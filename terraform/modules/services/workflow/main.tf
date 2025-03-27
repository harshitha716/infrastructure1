data "google_project" "project" {
}

resource "google_service_account" "service_account_workflow" {
  account_id   = "${var.project_prefix}-workflow"
  display_name = "workflow platform service account"
}

resource "google_service_account_iam_binding" "account_iam_workflow" {
  service_account_id = google_service_account.service_account_workflow.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "workflow_secrets_env" {
  secret_id = "${var.project_prefix}-workflow-secrets-env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "temporal_cert_key" {
  secret_id = "${var.project_prefix}-temporal-cert-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "temporal_cert" {
  secret_id = "${var.project_prefix}-temporal-cert"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "workflows_resource_credential_public_key" {
  secret_id = "${var.project_prefix}-workflows-resource-credential-public-key"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret" "workflows_resource_credential_private_key" {
  secret_id = "${var.project_prefix}-workflows-resource-credential-private-key"
  replication {
    auto {}
  }
}

module "workflow_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "WorkflowRole"
  title                = "Role for workflow service"
  description          = "Custom role for workflow action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_workflow.email}"]
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
data "google_project" "project" {
}

resource "google_service_account" "service_account_ap_agent" {
  account_id   = "${var.project_prefix}-ap-agent"
  display_name = "ap-agent platform service account"
}

resource "google_service_account_iam_binding" "account_iam_ap_agent" {
  service_account_id = google_service_account.service_account_ap_agent.name
  role               = "roles/iam.workloadIdentityUser"
  members            = local.members_list
}



resource "google_secret_manager_secret" "ap_agent_secrets_env" {
  secret_id = "${var.project_prefix}-ap-agent-secrets-env"
  replication {
    auto {}
  }
}

module "ap_agent_role" {
  source               = "../../custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "apagentRole"
  title                = "Role for ap-agent service"
  description          = "Custom role for ap-agent action"
  base_roles           = local.roles
  members              = ["serviceAccount:${google_service_account.service_account_ap_agent.email}"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings","datacatalog.categories.fineGrainedGet","spanner.sessions.create","container.clusters.get","container.clusters.list","container.cronJobs.get","container.cronJobs.getStatus","container.cronJobs.list","container.cronJobs.update","container.jobs.create","container.jobs.get","container.jobs.getStatus","container.jobs.list","container.jobs.update","container.jobs.updateStatus"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "storage-regional" {
  source      = "../../storage-regional"
  proj_prefix = var.project_prefix
  storage     = local.buckets-regional
}
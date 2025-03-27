locals {
  # List of roles that will be assigned to the github service account
  # github_roles = toset(var.roles)
  repositories = [ for repo in var.repositories : "${var.organization}/${repo}"]
}
resource "google_service_account" "github_actions_sa" {
  account_id   = "github-action-sa"
  display_name = "Service Account impersonated in GitHub Actions"
  project      = var.project_id
}

resource "google_service_account_iam_member" "oidc_impersonation" {
  for_each           = toset(local.repositories)
  service_account_id = google_service_account.github_actions_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${each.value}"
}

resource "google_project_iam_member" "github_actions_roles" {
for_each = toset(var.roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

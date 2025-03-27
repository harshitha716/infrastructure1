data "google_project" "project" {
}

resource "google_service_account" "sa" {
  account_id   = var.service_account_name
  display_name = var.service_account_name
}

resource "google_project_iam_member" "sa_role" {
  for_each = toset(var.iam_roles)

  role    = each.key
  member  = "serviceAccount:${google_service_account.sa.email}"
}

# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#authenticating_to
resource "google_service_account_iam_binding" "account-iam" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${var.k8s_service_account_namespace}/${var.k8s_service_account_name}]"
  ]
}
resource "google_service_account" "service_account" {
  account_id   = "${var.proj_prefix}-${var.id}"
  display_name = "${var.proj_prefix}-${var.id}"
}

resource "google_project_iam_member" "sa_role" {
  for_each = toset(var.roles)
  project = data.google_project.project.project_id  # Add this line
  role    = each.key
  member  = "serviceAccount:${google_service_account.service_account.email}"
}


data "google_project" "project" {
}

resource "google_service_account_iam_binding" "k8s_workload_identity_binding" {
  count = var.k8s_service_account ? 1 : 0
  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_service_account_namespace}/${var.k8s_service_account_name}]",

  ]
}


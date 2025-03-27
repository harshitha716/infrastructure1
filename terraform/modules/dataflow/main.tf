data "google_project" "project" {
}

data "google_compute_subnetwork" "subnet" {
  name   = local.parameters.network
  region = var.region
}

resource "google_dataflow_flex_template_job" "big_data_job" {
  for_each = var.enable_streaming_job ? toset(["1"]) : toset([])
  lifecycle {
    ignore_changes = all
  }
  depends_on = [
    google_project_iam_member.iam_member
  ]
  provider                = google-beta
  name                    = var.name
  container_spec_gcs_path = "gs://dataflow-templates-asia-southeast1/latest/flex/Spanner_Change_Streams_to_BigQuery"
  parameters              = local.parameters
}

resource "google_service_account" "service_account" {
  account_id   = "streaming-job-service-account"
  display_name = "${var.name}-service-account"
}


resource "google_project_iam_member" "iam_member" {
  depends_on = [
    module.dataflow_role
  ]
  project = var.project_id
  role    = module.dataflow_role.custom_role_id
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

module "dataflow_role" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "dataflow_streaming_job_role"
  title                = "DataflowStreamingJobRole"
  description          = "Custom role for dataflow streaming job"
  base_roles           = local.basic_roles
  members              = []
  permissions          = local.fine_grained_permissions
  excluded_permissions = ["resourcemanager.projects.list"]
}

resource "google_compute_firewall" "dataflow_worker" {
  name    = "${var.project_prefix}-streaming-dataflow"
  network = local.parameters.network
  allow {
    protocol = "tcp"
    ports    = ["12345-12346"]
  }
  log_config {
      metadata = "INCLUDE_ALL_METADATA"
  }
  target_tags = ["dataflow"]
  direction   = "INGRESS"
  priority    = "1000"
  source_ranges = [data.google_compute_subnetwork.subnet.ip_cidr_range]
}

locals {
  fine_grained_permissions = ["storage.buckets.create", "storage.buckets.createTagBinding", "storage.buckets.delete", "storage.buckets.deleteTagBinding", "storage.buckets.get", "storage.buckets.getIamPolicy", "storage.buckets.getObjectInsights", "storage.buckets.list", "storage.buckets.listEffectiveTags", "storage.buckets.listTagBindings", "storage.buckets.setIamPolicy", "storage.buckets.update", "storage.multipartUploads.abort", "storage.multipartUploads.create", "storage.multipartUploads.list", "storage.multipartUploads.listParts", "storage.objects.create", "storage.objects.delete", "storage.objects.get", "storage.objects.getIamPolicy", "storage.objects.list", "storage.objects.setIamPolicy", "storage.objects.update"]
  basic_roles              = ["roles/bigquery.dataEditor", "roles/cloudkms.cryptoKeyEncrypterDecrypter", "roles/spanner.databaseUser", "roles/spanner.viewer", "roles/dataflow.worker"]
  service_account_parameter = {
    serviceAccount = "${google_service_account.service_account.email}"
  }
  parameters = merge(var.parameters, local.service_account_parameter)
}

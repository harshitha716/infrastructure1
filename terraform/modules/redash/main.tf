data "google_compute_subnetwork" "subnet" {
  name   = var.network
  region = var.region
}

resource "google_service_account" "redash_all_sa" {
  account_id   = "redash-all-tables-sa"
  display_name = "redash-all-tables-service-account"
}


resource "google_service_account" "redash_restricted_raw_sa" {
  account_id   = "redash-restricted-raw-sa"
  display_name = "redash-restricted-raw-tables-service-account"
}


module "redash_roles_all_tables" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "redash_all_tables"
  title                = "RedashAllTables"
  description          = "Custom role for redash to read all tables"
  base_roles           = []
  members = []
  permissions          = local.redash_all_tables_permissions
}

module "redash_roles_restricted_tables" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "redash_restricted_tables"
  title                = "RedashRestrictedTables"
  description          = "Custom role for redash to read restricted tables"
  base_roles           = []
  members = []
  permissions          = local.redash_restricted_tables_permissions
}

resource "google_project_iam_member" "redash_all_iam_member" {
  depends_on = [
    module.redash_roles_all_tables
  ]
  project = var.project_id
  role     = module.redash_roles_all_tables.custom_role_id
  member   = "serviceAccount:${google_service_account.redash_all_sa.email}"
}

resource "google_project_iam_member" "redash_restricted_raw_iam_member" {
  depends_on = [
    module.redash_roles_restricted_tables
  ]
  project = var.project_id
  role     = module.redash_roles_restricted_tables.custom_role_id
  member   = "serviceAccount:${google_service_account.redash_restricted_raw_sa.email}"
}

resource "google_bigquery_table_iam_member" "raw_member" {
  lifecycle {
    create_before_destroy = true
  }
  for_each = toset(local.redash_raw_tables)
  project = var.project_id
  dataset_id = var.dataset_id
  table_id = "projects/${var.project_id}/datasets/${var.dataset_id}/tables/${each.value}"
  role = "roles/bigquery.dataViewer"
  member = "serviceAccount:${google_service_account.redash_restricted_raw_sa.email}"
}

resource "google_bigquery_table_iam_member" "raw_member_2" {
  lifecycle {
    create_before_destroy = true
  }
  for_each = toset(var.tables)
  project = var.project_id
  dataset_id = var.dataset_id
  table_id = "projects/${var.project_id}/datasets/${var.dataset_id}/tables/${each.value}"
  role = "roles/bigquery.dataViewer"
  member = "serviceAccount:${google_service_account.redash_restricted_raw_sa.email}"
}

resource "google_compute_resource_policy" "redash_vm_snapshot_schedule" {
  name   = "redash-vm-snapshot"
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "20:00"
      }
    }
    retention_policy {
      max_retention_days    = 14
    }
  }
}


resource "google_compute_firewall" "redash" {
  name    = "redash-vm"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["22","80","443"]
  }
  log_config {
      metadata = "INCLUDE_ALL_METADATA"
  }
  target_tags = ["redash"]
  direction   = "INGRESS"
  priority    = "1000"
  source_ranges = [data.google_compute_subnetwork.subnet.ip_cidr_range]
}



locals {
  redash_all_tables_permissions = ["bigquery.datasets.get","bigquery.jobs.create","bigquery.jobs.get","bigquery.jobs.update","bigquery.tables.get","bigquery.tables.getData","bigquery.tables.list"]
  redash_restricted_tables_permissions = ["bigquery.datasets.get","bigquery.jobs.create","bigquery.jobs.get","bigquery.jobs.update","bigquery.tables.get","bigquery.tables.list"]
  redash_raw_tables = [for table in var.tables : "${table}_Raw"]
}
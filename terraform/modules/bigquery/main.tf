data "google_project" "project" {
}

resource "google_bigquery_dataset" "bq_dataset" {
  dataset_id    = var.dataset_id
  friendly_name = var.name
  description   = var.description
  location      = var.location
  labels        = var.labels
  default_encryption_configuration {
    kms_key_name = module.kms_bigquery.crypto_key_id
  }
}

module "kms_bigquery" {
  source          = "../../modules/kms"
  key_ring_name   = "${var.project_prefix}-${var.dataset_id}-bigquery"
  location        = var.location
  crypto_key_name = "${var.project_prefix}-${var.dataset_id}-bigquery"
  iam_member      = local.bq_iam_member
}

locals {
  bq_iam_member = "serviceAccount:bq-${data.google_project.project.number}@bigquery-encryption.iam.gserviceaccount.com"
}

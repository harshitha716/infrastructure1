//Service Accounts 

resource "google_service_account" "backup_sa" {
  account_id   = "${var.project_prefix}-backup-sa"
  display_name = "Spanner Backup Function Service Account"
}

resource "google_project_iam_member" "backup_sa_spanner_iam" {
  project = var.project_id
  role    = "roles/spanner.backupWriter"
  member  = "serviceAccount:${google_service_account.backup_sa.email}"
}

// PubSub for trigger 

resource "google_pubsub_topic" "backup_topic" {
  for_each = var.database_ids
  project  = var.project_id
  name     = "${var.project_prefix}-${each.value}-backup"
  kms_key_name = google_kms_crypto_key.pubsub.id
}

resource "google_pubsub_topic_iam_member" "backup_sa_pubsub_sub_iam" {
  for_each   = var.database_ids
  project    = var.project_id
  topic      = "${var.project_prefix}-${each.value}-backup"
  role       = "roles/pubsub.subscriber"
  member     = "serviceAccount:${google_service_account.backup_sa.email}"
  depends_on = [google_pubsub_topic.backup_topic]
}

//Scheduler

resource "google_cloud_scheduler_job" "backup_job" {
  for_each    = var.database_ids
  region      = var.region
  project     = var.project_id
  name        = "${var.project_prefix}-${each.value}-backup-job"
  description = "Backup job for database - ${each.value}"
  schedule    = var.schedule
  time_zone   = var.time_zone
  pubsub_target {
    topic_name = google_pubsub_topic.backup_topic[each.value].id
    data       = base64encode("{\"Database\":\"projects/${var.project_id}/instances/${var.spanner_instance_id}/databases/${each.value}\", \"Expire\": \"${var.backup_retention_period}\"}")
  }
}


//Cloud Function

resource "google_storage_bucket" "backupfunction" {
  name                        = "${var.project_prefix}-backup-function"
  storage_class               = "REGIONAL"
  location                    = var.region
  force_destroy               = "true"
  uniform_bucket_level_access = var.uniform_bucket_level_access
  versioning {
    enabled = true
  }
  dynamic logging {
    for_each = var.log_bucket == null ? [] : [var.log_bucket]
    content {
      log_bucket = var.log_bucket
      log_object_prefix = var.log_object_prefix
    }
  }
}

data "archive_file" "local_backup_source" {
  type        = "zip"
  source_dir  = abspath("${path.module}/backup")
  output_path = "${var.local_output_path}/backup.zip"
}

resource "google_storage_bucket_object" "gcs_functions_backup_source" {
  name   = "backup.${data.archive_file.local_backup_source.output_md5}.zip"
  bucket = google_storage_bucket.backupfunction.name
  source = data.archive_file.local_backup_source.output_path
  lifecycle {
            ignore_changes = all
    }
}

resource "google_cloudfunctions_function" "spanner_backup_function" {
  lifecycle {
    ignore_changes = [
      max_instances,
    ]
  }
  for_each            = var.database_ids
  name                = "${var.project_prefix}-${each.value}-spanner-backup"
  project             = var.project_id
  region              = var.region
  available_memory_mb = "256"
  entry_point         = "SpannerCreateBackup"
  runtime             = "go120"
  timeout             = 120
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.backup_topic[each.value].id
  }
  source_archive_bucket = google_storage_bucket.backupfunction.name
  source_archive_object = google_storage_bucket_object.gcs_functions_backup_source.name
  service_account_email = google_service_account.backup_sa.email
  depends_on            = [google_pubsub_topic.backup_topic]
  environment_variables = {
    WEBHOOKURL   = var.webhook_url
    PROJECTNAME  = var.project_id
    INSTANCENAME = var.spanner_instance_id
    DATABASENAME = "${each.value}"
  }
}

resource "google_kms_key_ring" "pubsub" {
  name     = "${var.project_prefix}-spannerbackup-pubsub"
  location = var.region
}

resource "google_kms_crypto_key" "pubsub" {
  name            = "${var.project_prefix}-spannerbackup-pubsub"
  key_ring        = google_kms_key_ring.pubsub.id
  rotation_period = var.kms_rotation_duration

  lifecycle {
    prevent_destroy = true
  }
}
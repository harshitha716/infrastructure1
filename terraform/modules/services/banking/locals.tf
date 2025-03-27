locals {
  members_map  = { for x in var.service_accounts : x.name => x }
  members_list = [for k, v in local.members_map : "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[${v.namespace}/${k}]"]

  env = split("-", var.project_prefix)[1]
  buckets = concat([{
    name        = "banking-documents"
    enable_cors = true
    log_bucket  = "${var.project_prefix}-gcs-logging"
    cors = {
      origin          = var.cors_origins
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
    },
  # {
  #   name        = "recon"
  #   enable_cors = true
  #   log_bucket  = "${var.project_prefix}-gcs-logging" 
  #   cors = {
  #     origin          = var.cors_origins 
  #     method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
  #     response_header = ["*"]
  #     max_age_seconds = 3600
  #   }
  # }
], var.buckets)

  buckets-regional = concat([{
    name        = "banking-documents-regional"
    enable_cors = true
    log_bucket  = "${var.project_prefix}-gcs-logging"
    cors = {
      origin          = var.cors_origins
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
    },
    {
    name        = "recon"
    enable_cors = true
    log_bucket  = "${var.project_prefix}-gcs-logging" 
    cors = {
      origin          = var.cors_origins 
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
    },
    {
    name        = "databricks-data"
    enable_cors = true
    log_bucket  = "${var.project_prefix}-gcs-logging" 
    cors = {
      origin          = var.cors_origins 
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
    }
], var.buckets-regional)

}

resource "google_monitoring_alert_policy" "vm_cpu_alert_policy" {
  display_name = "VM CPU Utilization High"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s"
  }
  notification_channels = local.notification_channels
  conditions {
    display_name = "VM Instance - CPU utilization"
    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND resource.labels.project_id = \"${var.project_id}\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      comparison      = "COMPARISON_GT"
      duration        = "120s"
      threshold_value = "0.85"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
      trigger {
        count = 3
      }
    }
  }

  user_labels = var.user_labels
}

resource "google_monitoring_alert_policy" "cloudsql_disk_alert_policy" {
  display_name = "Cloud SQL Database Disk utilization"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s"
  }
  notification_channels = local.notification_channels
  conditions {
    display_name = "Cloud SQL Database - Disk utilization"
    condition_threshold {
        
      filter          = "resource.labels.project_id = \"${var.project_id}\" AND resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/disk/utilization\""
      comparison      = "COMPARISON_GT"
      duration        = "120s"
      threshold_value = "80"
      aggregations {
        alignment_period   = "120s"
        per_series_aligner = "ALIGN_MEAN"
      }
      trigger {
        count = 3
      }
    }
  }

  user_labels = var.user_labels
}


resource "google_monitoring_alert_policy" "cloudsql_read_io_alert_policy" {
  display_name = "Cloud SQL Disk Read IO"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s"
  }
  notification_channels = local.notification_channels
  conditions {
    display_name = "Cloud SQL Database - Disk read IO"
    condition_threshold {
        
      filter          = "resource.labels.project_id = \"${var.project_id}\" AND resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/disk/read_ops_count\""
      comparison      = "COMPARISON_GT"
      duration        = "120s"
      threshold_value = 100
      aggregations {
        alignment_period   = "120s"
        per_series_aligner = "ALIGN_RATE"
      }
      trigger {
        count = 3
      }
    }
  }

  user_labels = var.user_labels
}



resource "google_monitoring_alert_policy" "cloudsql_write_io_alert_policy" {
  display_name = "Cloud SQL Disk write IO"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s"
  }
  notification_channels = local.notification_channels
  conditions {
    display_name = "Cloud SQL Database - Disk write IO"
    condition_threshold {
        
      filter          = "resource.labels.project_id = \"${var.project_id}\" AND resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/disk/write_ops_count\""
      comparison      = "COMPARISON_GT"
      duration        = "120s"
      threshold_value = 100
      aggregations {
        alignment_period   = "120s"
        per_series_aligner = "ALIGN_RATE"
      }
      trigger {
        count = 3
      }
    }
  }
  user_labels = var.user_labels
}


resource "google_monitoring_alert_policy" "k8s_node_allocatable_cpu_utilization_policy" {
  display_name = "Kubernetes Node - CPU allocatable utilization"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s"
  }
  notification_channels = local.notification_channels
  conditions {
    display_name = "Kubernetes Node - CPU allocatable utilization"
    condition_threshold {
        
      filter          = "resource.labels.project_id = \"${var.project_id}\" AND resource.type = \"k8s_node\" AND metric.type = \"kubernetes.io/node/cpu/allocatable_utilization\""
      comparison      = "COMPARISON_GT"
      duration        = "120s"
      threshold_value = 100
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
      trigger {
        count = 3
      }
    }
  }
  user_labels = var.user_labels
}
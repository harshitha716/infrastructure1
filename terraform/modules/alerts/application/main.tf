resource "google_monitoring_alert_policy" "pubsub_oldesk_ack_aget_alert_policy" {
  display_name = "Cloud Pub/Sub Topic - Oldest retained acked message age by region"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s"
  }
  notification_channels = local.notification_channels
  conditions {
    display_name = "Cloud Pub/Sub Topic - Oldest retained acked message age by region"
    condition_threshold {
      filter          = "resource.type = \"pubsub_topic\" AND metric.type = \"pubsub.googleapis.com/topic/oldest_retained_acked_message_age_by_region\""
      comparison      = "COMPARISON_GT"
      duration        = "120s"
      threshold_value = "10"
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

resource "google_monitoring_alert_policy" "spanner_cpu_alert_policy" {
  display_name = "Spanner CPU Utilization Alert above 45%"
  combiner     = "OR"
  alert_strategy {
    auto_close = "604800s" # Auto-close after 7 days
  }
  notification_channels = local.notification_channels
  
  conditions {
    display_name = "Spanner CPU Utilization"
    condition_threshold {
      filter          = "resource.type=\"spanner_instance\" AND metric.type=\"spanner.googleapis.com/instance/cpu/utilization\""
      comparison      = "COMPARISON_GT"
      duration        = "300s" # 5 minutes
      threshold_value = "0.45"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
      trigger {
        count = 1
      }
    }
  }

  user_labels = var.user_labels
}
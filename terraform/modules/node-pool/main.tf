
resource "google_container_node_pool" "managed_pool" {
  lifecycle {
    create_before_destroy = true
  }
  cluster  = var.cluster_name
  location = var.cluster_location

  name     = "${var.node_pool_name}"
  node_locations = var.node_locations
  max_pods_per_node  = 50
  # initial_node_count = var.initial_node_count
  dynamic autoscaling {
    for_each = var.autoscaling.enabled ? toset([1]): toset([])
    content{
        min_node_count = var.autoscaling.min_node_count
        max_node_count = var.autoscaling.max_node_count
    }
  }
  node_count = var.node_count
  node_config {
    preemptible  = var.preemptible_node
    machine_type = var.node_pool_machine_type
    disk_size_gb = var.node_pool_root_disk_size
    tags         = var.node_pool_network_tags 
    
    #Service Account
    service_account = var.google_service_account_email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    dynamic "shielded_instance_config" {
      for_each = var.shielded_instance_config != {} ? toset([1]): toset([])
      content {
        enable_secure_boot = var.shielded_instance_config.enable_secure_boot
      }
    }
    labels = var.labels
    
    # For accessing Google API : https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#enable_on_cluster
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    dynamic taint {
      for_each = var.taints
      content{
        key    = taint.key
        value  = taint.value
        effect = "NO_SCHEDULE"
      }
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
  }
}
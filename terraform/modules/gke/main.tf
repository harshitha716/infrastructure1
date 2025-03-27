locals {
  zone                          = var.zone == null ? data.google_compute_zones.available.names[0] : var.zone
  location                      = var.location_zonal_type ? local.zone : var.region
  vpn_ip_names                  = [for i, v in var.vpn_ips : "vpn-ip-${i}"]
  vpn_ips_map                   = zipmap(local.vpn_ip_names, var.vpn_ips)
  github_actions_ips_map        = {}
  master_authorized_cidr_blocks = merge(local.vpn_ips_map, local.github_actions_ips_map)
}

data "google_compute_zones" "available" {
  region = var.region
}


data "google_project" "project" {
}

resource "google_container_cluster" "main" {

  name           = "${var.proj_prefix}-gke-cluster${var.name_suffix}"
  location       = local.location
  network        = var.vpc
  subnetwork     = var.subnetwork
  min_master_version = var.k8s_version
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  release_channel {
    channel = var.channel_type
  }


  resource_labels = {
    env = var.environment
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    # gce_persistent_disk_csi_driver_config {
    #   enabled = true
    # }
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {} #Automatically creates secondary subnets

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block #cidrsubnet(var.master_ipv4_cidr_block,4,0) # to make cidr /26
  }

  # master_authorized_networks_config {
  #   dynamic "cidr_blocks" {
  #     for_each = local.master_authorized_cidr_blocks
  #     content {
  #       display_name = cidr_blocks.key
  #       cidr_block   = cidr_blocks.value
  #     }
  #   }
  # }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "20:00"
    }
  }

  enable_shielded_nodes = true

  # For accessing Google API
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

}

resource "google_service_account" "node" {
  account_id   = google_container_cluster.main.name
  display_name = google_container_cluster.main.name
}

resource "google_project_iam_member" "sa_role" {
  for_each = toset(["roles/artifactregistry.reader", "roles/logging.logWriter", "roles/monitoring.metricWriter"])
  project = data.google_project.project.project_id  # Add this line

  role   = each.key
  member = "serviceAccount:${google_service_account.node.email}"
}


# Ingress Static IP
resource "google_compute_address" "ingress" {
  count = var.ingress_static_ip ? 1 : 0
  name  = "${var.proj_prefix}-ingress-lb-ip"
  region = var.region
}
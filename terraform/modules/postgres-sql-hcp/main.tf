#locals {
#  vpc = module.vpc-global.network
#}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "${var.project_prefix}-pgsql-hcp-subnet"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_name
  depends_on    = [var.vpc_name]
  lifecycle {
    ignore_changes = [
      description,
      prefix_length
    ]
  }
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta
  network                 = var.vpc_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [var.vpc_name]
  lifecycle {
    ignore_changes = [
      reserved_peering_ranges
    ]
  }
}

resource "google_sql_database_instance" "instance" {
  name   = var.name
  region = var.region
  database_version = var.postgres_version
  depends_on = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = var.deletion_protection
  settings {
    tier              = var.tier
    activation_policy = "ALWAYS"
    availability_type = var.availability_type
    disk_size         = var.disk_size_gb
    ip_configuration {
      private_network = var.vpc_name
      ipv4_enabled    = var.public_ipv4_connectivity.enabled
      dynamic "authorized_networks" {
        for_each = var.public_ipv4_connectivity.authorized_networks
        iterator = authorized_networks
        content {
          name  = authorized_networks.key
          value = authorized_networks.value
        }
      }
    }
    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
    backup_configuration {
      enabled                        = var.enable_backups
      start_time                     = "20:00"
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
    }
    maintenance_window {
      day  = 3
      hour = 20
    }
    dynamic "database_flags" {
      for_each = var.database_flags
      iterator = flag

      content {
        name  = flag.value["name"]
        value = flag.value["value"]
      }
    }
    user_labels = merge({
      team       = "infra"
      env        = var.env
      project    = var.project
      managed-by = "terraform"
    }, var.user_labels)
  }
  lifecycle {
    ignore_changes = [
      settings[0].disk_size,
      settings[0].backup_configuration,
      settings[0].insights_config,
      settings[0].maintenance_window
    ]
    prevent_destroy = false
  }
}

resource "google_sql_user" "users" {
  instance = google_sql_database_instance.instance.name
  name     = var.postgres_username
  password = var.postgres_password
  lifecycle {
      ignore_changes = [
        password
      ]
    }
}

output "private_ip_name" {
  value = google_compute_global_address.private_ip_address.name
}

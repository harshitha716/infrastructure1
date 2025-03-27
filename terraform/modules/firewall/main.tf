# # public - allow ingress from anywhere
# resource "google_compute_firewall" "public_allow_all_inbound" {
#   name = "${var.proj_prefix}-public-allow-ingress"

#   network = var.network

#   target_tags   = ["public"]
#   direction     = "INGRESS"
#   source_ranges = ["0.0.0.0/0"]

#   priority = "1000"

#   allow {
#     protocol = "all"
#   }
# }


# private - allow ingress from within this network
# resource "google_compute_firewall" "private_allow_all_network_inbound" {
#   name = "${var.proj_prefix}-private-allow-ingress"

#   network = var.network

#   target_tags = ["private"]
#   direction   = "INGRESS"

#   source_ranges = var.private_source_ranges

#   priority = "1000"

#   allow {
#     protocol = "all"
#   }
# }


# office - allow ingress from office networks
resource "google_compute_firewall" "office_allow_network_inbound" {
  name = "${var.proj_prefix}-office-allow-ingress"

  network = var.network
  dynamic "log_config" {
    for_each = var.enable_logging ? ["enable_logging"] : []
    content {
      metadata = "EXCLUDE_ALL_METADATA"
    }
  }
  target_tags = ["office"]
  direction   = "INGRESS"
  priority    = "1000"
  source_ranges = var.office_ip_list

  allow {
    protocol = "tcp"
    ports    = ["121"]
  }
}

# iap (Identity-Aware Proxy) - allow ingress from iap - https://cloud.google.com/iap/docs/using-tcp-forwarding
resource "google_compute_firewall" "iap_allow_network_inbound" {
  name = "${var.proj_prefix}-iap-allow-ingress"

  network = var.network
  dynamic "log_config" {
    for_each = var.enable_logging ? ["enable_logging"] : []
    content {
      metadata = "EXCLUDE_ALL_METADATA"
    }
  }
  target_tags = ["iap"]
  direction   = "INGRESS"
  priority    = "1000"
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["121", "22"]
  }
}

#openvpn
resource "google_compute_firewall" "ovpn_allow_network_inbound" {
  name = "${var.proj_prefix}-ovpn-allow-ingress"

  network = var.network
  dynamic "log_config" {
    for_each = var.enable_logging ? ["enable_logging"] : []
    content {
      metadata = "EXCLUDE_ALL_METADATA"
    }
  }
  target_tags = ["ovpn"]
  direction   = "INGRESS"
  priority    = "1000"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

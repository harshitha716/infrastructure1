# locals {
#   egress_static_ips = [
#     google_compute_address.egress-static-ip,
#     google_compute_address.egress-static-ip-b,
#     google_compute_address.egress-static-ip-c,
#     google_compute_address.egress-static-ip-d,
#   ]
# }

resource "google_compute_network" "vpc_network" {
  name                    = "${var.proj_prefix}-vpc"
  auto_create_subnetworks = var.auto_create_subnets
}

resource "google_compute_router" "router" {
  name    = "${var.proj_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "random_id" "this" {
  byte_length = 2
  keepers = {
    force_recreate = "1"
  }
}

resource "google_compute_address" "nat_ip" {
  count  = var.nat_ip_count
  name   = "${var.proj_prefix}-nat-ip-${count.index + 1}-${random_id.this.hex}"
  region = var.region
}

# resource "google_compute_address" "egress-static-ip" {
#   provider = google-beta

#   name   = "${var.proj_prefix}-egress-static-ip"
#   labels = local.common_labels
# }

# resource "google_compute_address" "egress-static-ip-b" {
#   provider = google-beta

#   name   = "${var.proj_prefix}-egress-static-ip-b"
#   labels = local.common_labels
# }

# resource "google_compute_address" "egress-static-ip-c" {
#   provider = google-beta

#   name   = "${var.proj_prefix}-egress-static-ip-c"
#   labels = local.common_labels
# }

# resource "google_compute_address" "egress-static-ip-d" {
#   provider = google-beta

#   name   = "${var.proj_prefix}-egress-static-ip-d"
#   labels = local.common_labels
# }

resource "google_compute_router_nat" "nat" {
  name                                = "${var.proj_prefix}-router-nat"
  router                              = google_compute_router.router.name
  region                              = google_compute_router.router.region
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option              = "MANUAL_ONLY"
  min_ports_per_vm                    = 1024
  enable_endpoint_independent_mapping = false
  nat_ips = google_compute_address.nat_ip.*.self_link

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

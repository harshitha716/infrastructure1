
# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.proj_prefix}-vpc"
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = "REGIONAL"
  #delete_default_routes_on_create = true
}

# # SUBNETS
# resource "google_compute_subnetwork" "public" {
#   count                    = !var.auto_create_subnetworks ? 1 : 0
#   name                     = "${local.proj_regioncode_prefix}-public-1"
#   ip_cidr_range            = var.public_subnet_cidr
#   region                   = var.region
#   network                  = google_compute_network.vpc.self_link
#   private_ip_google_access = true

#   dynamic "secondary_ip_range" {
#     for_each = var.public_subnet_secondary_cidrs
#     content {
#       range_name    = secondary_ip_range.key
#       ip_cidr_range = secondary_ip_range.value
#     }
#   }

#   dynamic "log_config" {
#     for_each = var.log_config == null ? [] : tolist([var.log_config])

#     content {
#       aggregation_interval = var.log_config.aggregation_interval
#       flow_sampling        = var.log_config.flow_sampling
#       metadata             = var.log_config.metadata
#     }
#   }
# }

# resource "google_compute_subnetwork" "private" {
#   count                    = !var.auto_create_subnetworks ? 1 : 0
#   name                     = "${local.proj_regioncode_prefix}-private-1"
#   ip_cidr_range            = var.private_subnet_cidr
#   region                   = var.region
#   network                  = google_compute_network.vpc.self_link
#   private_ip_google_access = true

#   dynamic "secondary_ip_range" {
#     for_each = var.private_subnet_secondary_cidrs
#     content {
#       range_name    = secondary_ip_range.key
#       ip_cidr_range = secondary_ip_range.value
#     }
#   }

#   dynamic "log_config" {
#     for_each = var.log_config == null ? [] : tolist([var.log_config])

#     content {
#       aggregation_interval = var.log_config.aggregation_interval
#       flow_sampling        = var.log_config.flow_sampling
#       metadata             = var.log_config.metadata
#     }
#   }
# }

# resource "google_compute_subnetwork" "private_proxy" {
#   count         = !var.auto_create_subnetworks ? 1 : 0
#   name          = "${local.proj_regioncode_prefix}-private-proxy-1"
#   ip_cidr_range = var.private_proxy_subnet_cidr
#   region        = var.region
#   purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
#   role          = "ACTIVE"
#   network       = google_compute_network.vpc.self_link

#   dynamic "secondary_ip_range" {
#     for_each = var.private_proxy_subnet_secondary_cidrs
#     content {
#       range_name    = secondary_ip_range.key
#       ip_cidr_range = secondary_ip_range.value
#     }
#   }

#   dynamic "log_config" {
#     for_each = var.log_config == null ? [] : tolist([var.log_config])

#     content {
#       aggregation_interval = var.log_config.aggregation_interval
#       flow_sampling        = var.log_config.flow_sampling
#       metadata             = var.log_config.metadata
#     }
#   }
# }

# ROUTER
resource "google_compute_router" "router" {
  name    = "${var.proj_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.self_link
}

# NAT IPs
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

# NAT
resource "google_compute_router_nat" "nat" {
  name   = "${local.proj_regioncode_prefix}-nat"
  router = google_compute_router.router.name
  region = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_ip.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

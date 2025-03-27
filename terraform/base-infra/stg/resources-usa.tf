# module "vpc-usa" {
#   source      = "../../modules/vpc-global"
#   proj_prefix = local.project_prefix_usa
#   region      = var.region_usa
# }

# module "firewall" {
#   source         = "../../modules/firewall"
#   proj_prefix    = local.project_prefix
#   network        = module.vpc.network
#   office_ip_list = var.firewall_office_ip_list
# }

# #Networking

# Define a new router for the usa region
resource "google_compute_router" "router_usa" {
  name    = "zamp-stg-usa-router"
  region  = var.region_usa
  network = module.vpc.vpc_id # Reference the existing VPC network
}

resource "random_id" "that" {
  byte_length = 2
  keepers = {
    force_recreate = "1"
  }
}

# Define the new NAT gateway in the USA region
resource "google_compute_address" "nat_ip_usa" {
  count  = var.nat_ip_count_usa
  name   = "zamp-stg-usa-nat-ip-${count.index + 1}-${random_id.that.hex}-usa"
  region = var.region_usa
}
resource "google_compute_router_nat" "nat_usa" {
  name                               = "zamp-stg-usa-nat"
  router                             = google_compute_router.router_usa.name
  region                             = var.region_usa
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option              = "MANUAL_ONLY"
  min_ports_per_vm                    = 2048
  enable_endpoint_independent_mapping = false
  nat_ips                             = google_compute_address.nat_ip_usa.*.self_link

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# Update GKE module to use the new NAT gateway in the USA region
module "gke_v2_usa" {
  source                   = "../../modules/gke"
  proj_prefix              = local.project_prefix_usa
  environment              = var.environment_usa
  name_suffix              = "-usa"
  region                   = var.region_usa
  vpc                      = module.vpc.network
  master_ipv4_cidr_block   = "10.110.8.0/28" # /28 is required
  network_tags             = ["gke-dev-nodes"]
  vpn_ips                  = var.firewall_office_ip_list
  node_pool_min_node_count = 0
  node_pool_max_node_count = 3
  location_zonal_type      = true
  k8s_version              = "1.27.11-gke.1062001"
  # nat_ips                 = [google_compute_address.nat_ip_eu[0].address]# Use the new NAT IP in the EU region
}


module "gke-repo_usa" {
  source        = "../../modules/gar"
  region        = var.region_usa
  repository_id = "${local.project_prefix_usa}-container-repo"
}

module "helm-repo_usa" {
  source        = "../../modules/gar"
  region        = var.region_usa
  repository_id = "${local.project_prefix_usa}-helm-repository"
}

module "node-pool-v2-usa" {
  source         = "../../modules/node-pool"
  proj_prefix    = local.project_prefix_usa
  node_pool_name = "gke-node-pool-v2-usa"
  environment    = var.environment_usa
  autoscaling = {
    enabled        = true
    min_node_count = 2
    max_node_count = 4
  }
  cluster_name                 = module.gke_v2_usa.cluster_name
  cluster_location             = module.gke_v2_usa.cluster_location
  google_service_account_email = module.gke_v2_usa.google_service_account_email
  node_pool_machine_type       = "n2-standard-2"
  preemptible_node             = false
  node_pool_network_tags       = ["gke-dev-nodes"]
  node_pool_root_disk_size     = 100
  labels = {
    env  = var.environment_usa
    type = "managed"
    role = "worker"
    workload = "zamp"
    airbyte = "true"
  }
}


module "gcs_buckets_usa" {
  source      = "../../modules/gcs"
  proj_prefix = "${local.project_prefix_usa}"
  location    = "US"
}

module "k8s-external-secret-store-sa_usa" {
  depends_on                    = [module.gke_v2_usa]
  k8s_service_account           = true
  source                        = "../../modules/sa"
  id                            = "k8s-es-usa"
  proj_prefix                   = local.project_prefix_usa
  project_id                    = data.google_project.project.project_id
  roles                         = ["roles/secretmanager.secretAccessor"]
  k8s_service_account_name      = "kubernetes-external-secrets"
  k8s_service_account_namespace = "external-secrets"

}


data "google_project" "project-usa" {
}

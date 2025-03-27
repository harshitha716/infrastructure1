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
  name    = "zamp-prd-usa-router"
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
  name   = "zamp-prd-usa-nat-ip-${count.index + 1}-${random_id.that.hex}-usa"
  region = var.region_usa
}
resource "google_compute_router_nat" "nat_usa" {
  name                               = "zamp-prd-usa-nat"
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
  master_ipv4_cidr_block   = "10.90.8.0/28" # /28 is required
  network_tags             = ["gke-dev-nodes"]
  vpn_ips                  = var.firewall_office_ip_list
  node_pool_min_node_count = 0
  node_pool_max_node_count = 3
  location_zonal_type      = true
  k8s_version              = "1.28.3-gke.1118000"
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
    min_node_count = 10
    max_node_count = 15
  }
  cluster_name                 = module.gke_v2_usa.cluster_name
  cluster_location             = module.gke_v2_usa.cluster_location
  google_service_account_email = module.gke_v2_usa.google_service_account_email
  node_pool_machine_type       = "n2-standard-4"
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

# # locals {
# #   project_prefix_eu = "zamp-prd-eu"
# # }

# # module "cloudspanner_eu" {
# #   source           = "../../modules/cloudspanner"
# #   proj_prefix      = local.project_prefix_eu
# #   region           = var.region_eu
# #   processing_units = var.cloudspanner_processing_units
# #   environment      = var.environment_eu
# #   #name_suffix           = "eu"  # Specify the name suffix for the EU region
# #   providers = {
# #     google = google.frank
# #   }
# # }

# module "openvpn_eu" {
#   source         = "../../modules/openvpn-eu"
#   # project_prefix = var.project_prefix_eu
#   instance_size  = "g1-small"
#   region         = var.region_eu
#   zone           = "${var.region_eu}-b"
#   vpc_name       = split("/", module.vpc.vpc_id)[4]
#   network        = "openvpn"
#   connectors = {
#     connector1 = var.open_vpn_token_eu #add as senstive variable in terraform cloud
#   }
#   providers = {
#     google = google.frank
#   }
# }

module "postgres_ap" {
  source                         = "../../modules/postgres-sql-v2"
  name                           = "${local.project_prefix_usa}-ap-pgsql-db"
  project_prefix                 = local.project_prefix_usa
  region                         = var.region_usa
  tier                           = var.tier
  disk_size_gb                   = var.disk_size_gb
  deletion_protection            = true
  enable_backups                 = true
  point_in_time_recovery_enabled = true
  query_insights_enabled         = true
  project_id                     = var.project_id
  vpc_name                       = module.vpc.network
  env                            = var.environment_usa
  project                        = var.project
  availability_type              = var.availability_type
  database_flags = [
    {
      name  = "log_min_duration_statement"
      value = "100"
    },
    {
      name  = "random_page_cost"
      value = "1.1"
    },
    {
      name  = "work_mem"
      value = "19660"
    },
    {
      name  = "max_connections"
      value = "400"
    },
  ]
  postgres_username = "postgresadmin"
  postgres_password = var.postgress_pass_ap
  postgres_version  = "POSTGRES_15"
  # public_ipv4_connectivity = {
  #   enabled = true
  #   # authorized_networks = {
  #   #   "Zamp-office-ip" = local.zamp-office-ip
  #   }
  # }
  depends_on = [module.vpc]
  providers = {
    google = google.frank
  }
}



# # # oidc for github

# # module "github_oidc" {
# #   depends_on = [ module.github_action_role ]
# #   source       = "../../modules/github-oidc"
# #   organization = "Zampfi"
# #   project_id   = var.project_id
# #   repositories = ["banking", "banking_dashboard", "bank_bridge", "internal_tools_dashboard", "destiny", "monza", "infrastructure", "docs", "pdf_generator", "payments-sdk", "access_management","tms_dashboard"]
# #   roles        = ["projects/${var.project_id}/roles/GithubAction"]
# #    providers = {
# #     google = google.frank
# #   }
# # }

data "google_project" "project-usa" {
}

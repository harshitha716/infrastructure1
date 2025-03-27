# module "vpc-eu" {
#   source      = "../../modules/vpc-global"
#   proj_prefix = local.project_prefix_eu
#   region      = var.region_eu
#   providers = {
#     google = google.frank
#   }
# }

# module "firewall" {
#   source         = "../../modules/firewall"
#   proj_prefix    = local.project_prefix
#   network        = module.vpc.network
#   office_ip_list = var.firewall_office_ip_list
#   providers = {
#     google = google.frank
#   }
# }

#Networking

# Define a new router for the EU region
resource "google_compute_router" "router_eu" {
  name    = "zamp-prd-eu-router"
  region  = var.region_eu
  network = module.vpc.vpc_id # Reference the existing VPC network
}

resource "random_id" "this" {
  byte_length = 2
  keepers = {
    force_recreate = "1"
  }
}

# Define the new NAT gateway in the EU region
resource "google_compute_address" "nat_ip_eu" {
  count  = var.nat_ip_count_eu
  name   = "zamp-prd-eu-nat-ip-${count.index + 1}-${random_id.this.hex}-eu"
  region = var.region_eu
}
resource "google_compute_router_nat" "nat_eu" {
  name                               = "zamp-prd-eu-nat"
  router                             = google_compute_router.router_eu.name
  region                             = var.region_eu
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option              = "MANUAL_ONLY"
  min_ports_per_vm                    = 2048
  enable_endpoint_independent_mapping = false
  nat_ips                             = google_compute_address.nat_ip_eu.*.self_link

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# Define any additional components for the EU region as needed

#Update GKE module to use the new NAT gateway in the EU region
# module "gke_v2_eu" {
#   source                   = "../../modules/gke"
#   proj_prefix              = local.project_prefix_eu
#   environment              = var.environment_eu
#   name_suffix              = "-eu"
#   region                   = var.region_eu
#   vpc                      = module.vpc.network
#   master_ipv4_cidr_block   = "10.90.8.0/28" # /28 is required
#   network_tags             = ["gke-dev-nodes-eu"]
#   vpn_ips                  = var.firewall_office_ip_list
#   node_pool_min_node_count = 0
#   node_pool_max_node_count = 3
#   location_zonal_type      = true
#   k8s_version              = "1.25.10-gke.2700"
#   # nat_ips                 = [google_compute_address.nat_ip_eu[0].address]# Use the new NAT IP in the EU region
#   providers = {
#     google = google.frank
#   }
# }


module "gke-repo_eu" {
  source        = "../../modules/gar"
  region        = var.region_eu
  repository_id = "${local.project_prefix_eu}-container-repo"
}

module "helm-repo_eu" {
  source        = "../../modules/gar"
  region        = var.region_eu
  repository_id = "${local.project_prefix_eu}-helm-repository"
}

# module "node-pool-v2-eu" {
#   source         = "../../modules/node-pool"
#   proj_prefix    = local.project_prefix_eu
#   node_pool_name = "gke-node-pool-v2-eu"
#   environment    = var.environment_eu
#   autoscaling = {
#     enabled        = true
#     min_node_count = 1
#     max_node_count = 3
#   }
#   cluster_name                 = module.gke_v2_eu.cluster_name
#   cluster_location             = module.gke_v2_eu.cluster_location
#   google_service_account_email = module.gke_v2_eu.google_service_account_email
#   node_pool_machine_type       = "n2-standard-2"
#   preemptible_node             = false
#   node_pool_network_tags       = ["gke-dev-nodes-eu"]
#   node_pool_root_disk_size     = 100
#   labels = {
#     env  = var.environment_eu
#     type = "managed"
#     role = "worker"
#   }
#    providers = {
#     google = google.frank
#   }
# }

# module "node-pool-v3-eu" {
#   source         = "../../modules/node-pool"
#   proj_prefix    = local.project_prefix_eu
#   node_pool_name = "gke-node-pool-v3-eu"
#   environment    = var.environment_eu
#   autoscaling = {
#     enabled        = true
#     min_node_count = 2
#     max_node_count = 4
#   }
#   cluster_name                 = module.gke_v2_eu.cluster_name
#   cluster_location             = module.gke_v2_eu.cluster_location
#   google_service_account_email = module.gke_v2_eu.google_service_account_email
#   node_pool_machine_type       = "n2-standard-4"
#   preemptible_node             = false
#   node_pool_network_tags       = ["gke-dev-nodes-eu"]
#   node_pool_root_disk_size     = 100
#   labels = {
#     env  = var.environment_eu
#     type = "managed"
#     role = "worker"
#   }
#    providers = {
#     google = google.frank
#   }
# }

module "gcs_buckets_eu" {
  source      = "../../modules/gcs"
  proj_prefix = "${local.project_prefix_eu}"
  location    = "EU"
}

# module "k8s-external-secret-store-sa_eu" {
#   depends_on                    = [module.gke_v2_eu]
#   k8s_service_account           = true
#   source                        = "../../modules/sa"
#   id                            = "k8s-es-eu"
#   proj_prefix                   = local.project_prefix_eu
#   project_id                    = data.google_project.project.project_id
#   roles                         = ["roles/secretmanager.secretAccessor"]
#   k8s_service_account_name      = "kubernetes-external-secrets"
#   k8s_service_account_namespace = "external-secrets"
# }

# locals {
#   project_prefix_eu = "zamp-prd-eu"
# }

# module "cloudspanner_eu" {
#   source           = "../../modules/cloudspanner"
#   proj_prefix      = local.project_prefix_eu
#   region           = var.region_eu
#   processing_units = var.cloudspanner_processing_units
#   environment      = var.environment_eu
#   #name_suffix           = "eu"  # Specify the name suffix for the EU region
#   providers = {
#     google = google.frank
#   }
# }

module "openvpn_eu" {
  source         = "../../modules/openvpn-eu"
  # project_prefix = var.project_prefix_eu
  instance_size  = "g1-small"
  region         = var.region_eu
  zone           = "${var.region_eu}-b"
  vpc_name       = split("/", module.vpc.vpc_id)[4]
  network        = "openvpn"
  connectors = {
    connector1 = var.open_vpn_token_eu #add as senstive variable in terraform cloud
  }
}

# module "postgres_eu" {
#   source                         = "../../modules/postgres-sql-v2"
#   name                           = "${local.project_prefix_eu}-roma-pgsql-db"
#   project_prefix                 = local.project_prefix_eu
#   region                         = var.region_eu
#   tier                           = var.tier
#   disk_size_gb                   = var.disk_size_gb
#   deletion_protection            = true
#   enable_backups                 = true
#   point_in_time_recovery_enabled = true
#   query_insights_enabled         = true
#   project_id                     = var.project_id
#   vpc_name                       = module.vpc.network
#   env                            = var.environment_eu
#   project                        = var.project
#   availability_type              = var.availability_type
#   database_flags = [
#     {
#       name  = "log_min_duration_statement"
#       value = "100"
#     },
#     {
#       name  = "random_page_cost"
#       value = "1.1"
#     },
#     {
#       name  = "work_mem"
#       value = "19660"
#     },
#     {
#       name  = "max_connections"
#       value = "400"
#     },
#   ]
#   postgres_username = "postgresadmin"
#   postgres_password = var.postgress_pass_eu
#   postgres_version  = "POSTGRES_14"
#   # public_ipv4_connectivity = {
#   #   enabled = true
#   #   # authorized_networks = {
#   #   #   "Zamp-office-ip" = local.zamp-office-ip
#   #   }
#   # }
#   depends_on = [module.vpc]
#   providers = {
#     google = google.frank
#   }
# }

# module "github_action_role" {
#   source               = "../../modules/custom-iam-role"
#   target_level         = "project"
#   target_id            = var.project_id
#   role_id              = "GithubAction"
#   title                = "Github Action"
#   description          = "Custom role for github action"
#   base_roles           = local.github_action_basic_roles
#   members              = []
#   permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache"]
#   excluded_permissions = ["resourcemanager.projects.list"]
#  providers = {
#     google = google.frank
#   }
# }

# # oidc for github

# module "github_oidc" {
#   depends_on = [ module.github_action_role ]
#   source       = "../../modules/github-oidc"
#   organization = "Zampfi"
#   project_id   = var.project_id
#   repositories = ["banking", "banking_dashboard", "bank_bridge", "internal_tools_dashboard", "destiny", "monza", "infrastructure", "docs", "pdf_generator", "payments-sdk", "access_management","tms_dashboard"]
#   roles        = ["projects/${var.project_id}/roles/GithubAction"]
#    providers = {
#     google = google.frank
#   }
# }

data "google_project" "project-eu" {
}

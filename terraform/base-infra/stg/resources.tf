locals {
  zamp-office-ip = "14.97.236.202/32"
}

module "vpc" {
  source      = "../../modules/vpc-global"
  proj_prefix = local.project_prefix
  region      = var.region
}

module "firewall" {
  source         = "../../modules/firewall"
  proj_prefix    = local.project_prefix
  network        = module.vpc.network
  office_ip_list = var.firewall_office_ip_list
}


module "gke_v2" {
  source                   = "../../modules/gke"
  proj_prefix              = local.project_prefix
  environment              = var.environment
  name_suffix              = "-v2"
  region                   = var.region
  vpc                      = module.vpc.network
  master_ipv4_cidr_block   = "10.40.9.0/28" # /28 is required
  network_tags             = ["gke-stg-nodes"]
  vpn_ips                  = var.firewall_office_ip_list
  node_pool_min_node_count = 0
  node_pool_max_node_count = 3
  location_zonal_type      = true
  k8s_version              = "1.24.10-gke.2300"
}


module "gke-repo" {
  source        = "../../modules/gar"
  region        = var.region
  repository_id = "${local.project_prefix}-container-repo"
}

module "node-pool-v2" {
  source         = "../../modules/node-pool"
  proj_prefix    = local.project_prefix
  node_pool_name = "gke-node-pool-v2"
  environment    = var.environment
  autoscaling = {
    enabled        = true
    min_node_count = 30
    max_node_count = 40
  }
  cluster_name                 = module.gke_v2.cluster_name
  cluster_location             = module.gke_v2.cluster_location
  google_service_account_email = module.gke_v2.google_service_account_email
  node_pool_machine_type       = "e2-small"
  shielded_instance_config = {
    enable_secure_boot = true
  }
  preemptible_node             = false
  node_pool_network_tags       = ["gke-stg-nodes"]
  labels = {
    env  = var.environment
    type = "managed"
    role = "worker"
  }
}

module "node-pool-herm" {
  source         = "../../modules/node-pool"
  proj_prefix    = local.project_prefix
  node_pool_name = "gke-node-pool-herm"
  environment    = var.environment
  autoscaling = {
    enabled        = true
    min_node_count = 5
    max_node_count = 10
  }
  cluster_name                 = module.gke_v2.cluster_name
  cluster_location             = module.gke_v2.cluster_location
  google_service_account_email = module.gke_v2.google_service_account_email
  node_pool_machine_type       = "e2-standard-4"
  shielded_instance_config = {
    enable_secure_boot = true
  }
  preemptible_node       = false
  node_pool_network_tags = ["gke-dev-nodes"]
  labels = {
    env  = var.environment
    type = "managed"
    role = "worker"
    app  = "herm"
  }
  taints = {
    effect = "NO_SCHEDULE"
  }
}

module "node-pool-general" {
  source         = "../../modules/node-pool"
  proj_prefix    = local.project_prefix
  node_pool_name = "gke-node-pool-general"
  environment    = var.environment
  autoscaling = {
    enabled        = true
    min_node_count = 2
    max_node_count = 3
  }
  cluster_name                 = module.gke_v2.cluster_name
  cluster_location             = module.gke_v2.cluster_location
  google_service_account_email = module.gke_v2.google_service_account_email
  node_pool_machine_type       = "e2-standard-4"
  shielded_instance_config = {
    enable_secure_boot = true
  }
  preemptible_node       = false
  node_pool_network_tags = ["gke-dev-nodes"]
  labels = {
    env  = var.environment
    type = "managed"
    role = "worker"
    app  = "highcompute"
  }
}
 

module "gcs_buckets" {
  source      = "../../modules/gcs"
  proj_prefix = local.project_prefix
  location    = "ASIA"
}

module "k8s-external-secret-store-sa" {
  k8s_service_account           = true
  source                        = "../../modules/sa"
  id                            = "k8s-es"
  proj_prefix                   = local.project_prefix
  roles                         = ["roles/secretmanager.secretAccessor"]
  project_id                    = data.google_project.project.project_id
  k8s_service_account_name      = "kubernetes-external-secrets"
  k8s_service_account_namespace = "external-secrets"
  depends_on                    = [module.gke_v2]
}


module "cloudspanner" {
  source           = "../../modules/cloudspanner"
  proj_prefix      = local.project_prefix
  region           = var.region
  processing_units = var.cloudspanner_processing_units
  environment      = var.environment
}

module "openvpn" {
  source         = "../../modules/openvpn"
  project_prefix = local.project_prefix
  instance_size  = "g1-small"
  region         = var.region
  vpc_name       = split("/", module.vpc.vpc_id)[4]
  network        = "openvpn"
  connectors = {
    connector1 = var.open_vpn_token #add as senstive variable in terraform cloud
  }
}

module "postgres" {
  source                         = "../../modules/postgres-sql"
  name                           = "${local.project_prefix}-roma-pgsql-db"
  project_prefix                 = local.project_prefix
  region                         = var.region
  tier                           = var.tier
  disk_size_gb                   = var.disk_size_gb
  deletion_protection            = true
  enable_backups                 = true
  point_in_time_recovery_enabled = true
  query_insights_enabled         = true
  project_id                     = var.project_id
  vpc_name                       = module.vpc.network
  env                            = var.environment
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
      value = "500"
    },
  ]
  postgres_username = "postgresadmin"
  postgres_password = var.postgress_pass
  postgres_version  = "POSTGRES_14"
  public_ipv4_connectivity = {
    enabled = true
    authorized_networks = {
      "Zamp-office-ip" = local.zamp-office-ip
    }
  }
  depends_on = [module.vpc]
}

module "postgres-recon" {
  source                         = "../../modules/postgres-sql-recon"
  name                           = "${local.project_prefix}-recon-pgsql-db"
  project_prefix                 = local.project_prefix
  region                         = var.region
  tier                           = var.tier
  disk_size_gb                   = var.disk_size_gb
  deletion_protection            = true
  enable_backups                 = true
  point_in_time_recovery_enabled = true
  query_insights_enabled         = true
  project_id                     = var.project_id
  vpc_name                       = module.vpc.network
  env                            = var.environment
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
      value = "500"
    },
  ]
  postgres_username = "postgresadmin"
  postgres_password = var.postgress_pass_recon
  postgres_version  = "POSTGRES_14"
  public_ipv4_connectivity = {
    enabled = true
    authorized_networks = {
      "Zamp-office-ip" = local.zamp-office-ip
    }
  }
  depends_on = [module.vpc]
}


module "postgres-hcp" {
  source                         = "../../modules/postgres-sql-hcp"
  name                           = "${local.project_prefix}-hcp-pgsql-db"
  project_prefix                 = local.project_prefix
  region                         = var.region
  tier                           = var.tier_hcp
  disk_size_gb                   = var.disk_size_gb
  deletion_protection            = true
  enable_backups                 = true
  point_in_time_recovery_enabled = true
  query_insights_enabled         = true
  project_id                     = var.project_id
  vpc_name                       = module.vpc.network
  env                            = var.environment
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
      value = "500"
    },
  ]
  postgres_username = "postgresadmin"
  postgres_password = var.postgress_pass_hcp
  postgres_version  = "POSTGRES_15"
  public_ipv4_connectivity = {
    enabled = true
    authorized_networks = {
      "Zamp-office-ip" = local.zamp-office-ip
    }
  }
  depends_on = [module.vpc]
}


###IAM NEW ROLES

module "developer-basic-1" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "developer_basic_type_1"
  title                = "Developer Basic Type 1"
  description          = "Developer Basic Type 1 Role"
  base_roles           = ["roles/logging.viewer"]
  members              = []
  permissions          = []
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "developer-basic-2" {
  source       = "../../modules/custom-iam-role"
  target_level = "project"
  target_id    = var.project_id
  role_id      = "developer_basic_type_2"
  title        = "Developer Basic Type 2"
  description  = "Developer Basic Type 2 Role"
  base_roles   = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/spanner.fineGrainedAccessUser"]
  members      = []
  permissions = ["storage.buckets.list","storage.buckets.get","spanner.instanceConfigs.get","spanner.instanceConfigs.list","spanner.instances.get","spanner.instances.list","spanner.instances.listEffectiveTags","spanner.instances.listTagBindings","spanner.databases.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "developer-admin-1" {
  source       = "../../modules/custom-iam-role"
  target_level = "project"
  target_id    = var.project_id
  role_id      = "developer_admin_type_1"
  title        = "Developer Admin Type 1"
  description  = "Developer Admin Type 1 Role"
  base_roles   = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/spanner.fineGrainedAccessUser"]
  members      = []
  permissions = ["storage.buckets.list","storage.buckets.get","spanner.instanceConfigs.get","spanner.instanceConfigs.list","spanner.instances.get","spanner.instances.list","spanner.instances.listEffectiveTags","spanner.instances.listTagBindings","spanner.databases.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "developer-admin-2" {
  source       = "../../modules/custom-iam-role"
  target_level = "project"
  target_id    = var.project_id
  role_id      = "developer_admin_type_2"
  title        = "Developer Admin Type 2"
  description  = "Developer Admin Type 2 Role"
  base_roles   = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/spanner.admin","roles/pubsub.admin","roles/cloudtasks.admin","roles/container.admin","roles/secretmanager.viewer","roles/secretmanager.secretAccessor","roles/secretmanager.secretVersionAdder"]
  members      = []
  permissions = ["storage.buckets.list","storage.buckets.get","spanner.instanceConfigs.get","spanner.instanceConfigs.list","spanner.instances.get","spanner.instances.list","spanner.instances.listEffectiveTags","spanner.instances.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "ops-1" {
  source       = "../../modules/custom-iam-role"
  target_level = "project"
  target_id    = var.project_id
  role_id      = "operations_type_1"
  title        = "Operations Type 1"
  description  = "Operations Type 1 Role"
  base_roles   = ["roles/pubsub.admin","roles/storage.objectAdmin"]
  members      = []
  permissions = ["storage.buckets.list",]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "cloudspanner-backup" {
  source                      = "../../modules/cloudspannerbackup"
  region                      = var.region
  project_prefix              = local.project_prefix
  project_id                  = var.project_id
  database_ids                = var.database_ids
  spanner_instance_id         = var.spanner_instance_id
  uniform_bucket_level_access = true
  backup_retention_period     = "12h"
  schedule                    = var.schedule
  webhook_url                 = var.WEBHOOK_URL
  log_bucket                  = "${local.project_prefix}-gcs-logging"
}

# OIDC for github action

module "github_action_role" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "GithubAction"
  title                = "Github Action"
  description          = "Custom role for github action"
  base_roles           = local.github_action_basic_roles
  members              = []
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "github_oidc" {
  depends_on = [ module.github_action_role ]
  source       = "../../modules/github-oidc"
  organization = "Zampfi"
  project_id   = var.project_id
  repositories = ["banking", "banking_dashboard", "bank_bridge", "internal_tools_dashboard", "destiny", "monza", "infrastructure", "docs", "pdf_generator", "payments-sdk", "access_management","tms_dashboard","alchemist","noon-recon","herm-frontend","pantheon","workflow_platform","web-automation-platform","platform-dashboard","application-platform","connectivity-platform","data_platform"]
  roles        = ["projects/${var.project_id}/roles/GithubAction"]
}


data "google_project" "project" {
}

module "roma-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "roma_basic"
  title                = "Roma Basic"
  description          = "Roma Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser", "roles/monitoring.viewer", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "roma-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "roma_admin"
  title                = "Roma Admin"
  description          = "Roma Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.databaseUser", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/bigquery.user", "roles/monitoring.viewer", "roles/pubsub.admin", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "cashcopilot-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "cashcopilot_basic"
  title                = "Cashcopilot Basic"
  description          = "Cashcopilot Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser", "roles/monitoring.viewer", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "cashcopilot-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "cashcopilot_admin"
  title                = "Cashcopilot Admin"
  description          = "Cashcopilot Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser","roles/bigquery.admin", "roles/monitoring.viewer", "roles/pubsub.admin", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
}
module "recon-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "recon_basic"
  title                = "Recon Basic"
  description          = "Recon Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/bigquery.admin", "roles/spanner.databaseUser", "roles/monitoring.viewer", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"] 
}

module "recon-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "recon_admin"
  title                = "Recon Admin"
  description          = "Recon Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser", "roles/bigquery.admin", "roles/monitoring.viewer", "roles/pubsub.admin", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.fineGrainedAccessUser"]  
}

module "payments-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "payments_basic"
  title                = "Payments Basic"
  description          = "Payments Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser", "roles/monitoring.viewer", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"] 
}
 
module "payments-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "payments_admin"
  title                = "Payments Admin"
  description          = "Payments Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser", "roles/bigquery.user", "roles/monitoring.viewer", "roles/pubsub.admin", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list"]
  excluded_permissions = ["resourcemanager.projects.list"] 
  
}

module "engineering-oncall" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "engineering_oncall"
  title                = "Engineering Oncall"
  description          = "Engineering Oncall Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/secretmanager.viewer", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/spanner.databaseUser", "roles/monitoring.viewer", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"]
  
}

# module "composer" {
#   source = "../../modules/composer"
#   name                     = "zamp-stg-airflow"
#   region                   = "asia-southeast1"
#   service_account          = "321085961264-compute@developer.gserviceaccount.com"
#   image_version            = "composer-3-airflow-2.10.2-build.0"
#   enable_private_environment = true
#   network                   = "projects/staging-351109/global/networks/zamp-stg-sg-vpc"
#   subnetwork                = "projects/staging-351109/regions/asia-southeast1/subnetworks/zamp-stg-sg-vpc"
#   resilience_mode           = "STANDARD_RESILIENCE"
#   depends_on                = [module.vpc]
#   enable_web_server_plugins = true
# }
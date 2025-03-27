
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
  enable_logging = true
}


module "gke" {
  source                   = "../../modules/gke"
  proj_prefix              = local.project_prefix
  environment              = var.environment
  region                   = var.region
  vpc                      = module.vpc.network
  master_ipv4_cidr_block   = var.gke_master_ipv4_cidr_block # /28 is required
  network_tags             = ["gke-dev-nodes"]
  vpn_ips                  = var.firewall_office_ip_list
  node_pool_min_node_count = 0
  node_pool_max_node_count = 3
  ingress_static_ip        = true
}



module "gke-repo" {
  source        = "../../modules/gar"
  region        = var.region
  repository_id = "${local.project_prefix}-container-repo"
}

module "helm-repo" {
  source        = "../../modules/gar"
  region        = var.region
  repository_id = "${local.project_prefix}-helm-repository"
}

module "node-pool-2" {
  source         = "../../modules/node-pool"
  proj_prefix    = local.project_prefix
  node_pool_name = "gke-node-pool-v2"
  environment    = var.environment
  autoscaling = {
    enabled        = true
    min_node_count = 15
    max_node_count = 30
  }
  cluster_name                 = module.gke.cluster_name
  cluster_location             = module.gke.cluster_location
  google_service_account_email = module.gke.google_service_account_email
  node_pool_machine_type       = "n2-standard-2"
  preemptible_node             = false
  node_pool_network_tags       = ["gke-dev-nodes"]
  node_pool_root_disk_size     = 100
  labels = {
    env  = var.environment
    type = "managed"
    role = "worker"
    workload = "zamp"
  }
}


module "node-pool-herm" {
  source         = "../../modules/node-pool"
  proj_prefix    = local.project_prefix
  node_pool_name = "gke-node-pool-herm"
  environment    = var.environment
  autoscaling = {
    enabled        = true
    min_node_count = 2
    max_node_count = 3
  }
  cluster_name                 = module.gke.cluster_name
  cluster_location             = module.gke.cluster_location
  google_service_account_email = module.gke.google_service_account_email
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
  project_id                    = data.google_project.project.project_id
  roles                         = ["roles/secretmanager.secretAccessor"]
  k8s_service_account_name      = "kubernetes-external-secrets"
  k8s_service_account_namespace = "external-secrets"
  depends_on                    = [module.gke]
}


module "cloudspanner" {
  source           = "../../modules/cloudspanner"
  proj_prefix      = local.project_prefix
  region           = var.region
  processing_units = var.cloudspanner_processing_units
  environment      = var.environment
}

data "google_project" "project" {
}

module "cloudspanner-restore" {
  source         = "../../modules/cloudspannerrestore"
  region         = var.region
  project_prefix = local.project_prefix
  project_id     = var.project_id
  log_bucket     = "${local.project_prefix}-gcs-logging"
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

module "cloudspanner-backup" {
  source                      = "../../modules/cloudspannerbackup"
  region                      = var.region
  project_prefix              = local.project_prefix
  project_id                  = var.project_id
  database_ids                = var.database_ids
  spanner_instance_id         = var.spanner_instance_id
  uniform_bucket_level_access = true
  backup_retention_period     = "168h"
  schedule                    = var.schedule
  webhook_url                 = var.WEBHOOK_URL
  log_bucket                  = "${local.project_prefix}-gcs-logging"
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
    {
      name  = "log_min_error_statement"
      value = "error"
    },
  ]
  postgres_username = "postgresadmin"
  postgres_password = var.postgress_pass
  postgres_version  = "POSTGRES_14"
  depends_on        = [module.vpc]
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
  depends_on = [module.vpc]
}


module "developer_readonly_role" {
  source         = "../../modules/custom-roles"
  role_name      = "developer-readonly"
  project_prefix = local.project_prefix
  member         = local.developer_readonly_members
  roles = [
    "roles/logging.viewer",
    "roles/spanner.fineGrainedAccessUser"
  ]
  granular_permissions = [
    "spanner.instanceConfigs.get",
    "spanner.instanceConfigs.list",
    "spanner.instances.get",
    "spanner.instances.list",
    "spanner.instances.listEffectiveTags",
    "spanner.instances.listTagBindings"
  ]
  conditional_roles = [
    {
      id         = "spanner-readonly"
      role       = "roles/spanner.databaseRoleUser"
      title      = "Spanner readonly access to certain tables"
      expression = "(resource.type == \"spanner.googleapis.com/DatabaseRole\" && resource.name.endsWith(\"/developer_readonly\"))"
    }
  ]
}




module "developer_admin_role" {
  source         = "../../modules/custom-roles"
  role_name      = "developer-admin"
  project_prefix = local.project_prefix

  member = local.developer_admin_members
  roles = [
    "roles/logging.viewer",
    "roles/spanner.viewer",
    "roles/spanner.databaseUser"
  ]
}

module "developer_admin_role_with_expiry" {
  count          = length(local.temporary_developer_admin_members) > 0 ? 1 : 0
  source         = "../../modules/custom-roles"
  role_name      = "developer-admin-expiring"
  project_prefix = local.project_prefix

  member = local.temporary_developer_admin_members
  roles = [
    "roles/logging.viewer",
    "roles/spanner.viewer"
  ]
  conditional_roles = [
    {
      id         = "spanner-rw-temp"
      role       = "roles/spanner.databaseUser"
      title      = "Temporary Spanner read write access to all tables"
      expression = "(request.time < timestamp(\"${local.temporary_access_timestamp}\"))"
    }
  ]
}



module "github_action_role" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "GithubAction"
  title                = "Github Action"
  description          = "Custom role for github action"
  base_roles           = local.basic_roles
  members              = ["serviceAccount:github-user@production-351109.iam.gserviceaccount.com"]
  permissions          = ["container.clusters.getCredentials", "compute.urlMaps.invalidateCache"]
  excluded_permissions = ["resourcemanager.projects.list"]
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
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "developer_basic_type_2"
  title                = "Developer Basic Type 2"
  description          = "Developer Basic Type 2 Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer"]
  members              = []
  permissions          = ["storage.buckets.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "developer-admin-1" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "developer_admin_type_1"
  title                = "Developer Admin Type 1"
  description          = "Developer Admin Type 1 Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin"]
  members              = []
  permissions          = ["storage.buckets.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "developer-admin-2" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "developer_admin_type_2"
  title                = "Developer Admin Type 2"
  description          = "Developer Admin Type 2 Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/spanner.admin", "roles/pubsub.admin", "roles/cloudtasks.admin", "roles/container.admin"]
  members              = []
  permissions          = ["storage.buckets.list", "storage.buckets.get", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


module "data-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "data_admin"
  title                = "Data Admin Type 1"
  description          = "Data Admin Type Role"
  base_roles           = ["roles/bigquery.admin", "roles/spanner.databaseUser", "roles/dataflow.developer"]
  members              = []
  permissions          = ["storage.buckets.get", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "data-admin-2" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "data_admin_type_2"
  title                = "Data Admin Type 2"
  description          = "Data Admin Type Role"
  base_roles           = ["roles/bigquery.dataViewer"]
  members              = []
  permissions          = []
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "ops-1" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "operations_type_1"
  title                = "Operations Type 1"
  description          = "Operations Type 1 Role"
  base_roles           = ["roles/pubsub.admin", "roles/storage.objectAdmin", "roles/bigquery.dataViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list","bigquery.jobs.create"]
  excluded_permissions = ["resourcemanager.projects.list"]
}


# OIDC for github action

module "github_oidc" {
  depends_on   = [module.github_action_role]
  source       = "../../modules/github-oidc"
  organization = "Zampfi"
  project_id   = var.project_id
  repositories = ["banking", "banking_dashboard", "bank_bridge", "internal_tools_dashboard", "destiny", "monza", "infrastructure", "docs", "pdf_generator", "payments-sdk", "access_management", "tms_dashboard","alchemist","noon-recon","herm-frontend","pantheon","workflow_platform","web-automation-platform","platform-dashboard","application-platform","connectivity-platform","data_platform"]
  roles        = ["projects/${var.project_id}/roles/GithubAction"]
}


module "roma-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "roma_basic"
  title                = "Roma Basic"
  description          = "Roma Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list", "storage.buckets.get"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "roma-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "roma_admin"
  title                = "Roma Admin"
  description          = "Roma Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.databaseReader", "roles/pubsub.viewer", "roles/pubsub.publisher","roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list",]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "cashcopilot-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "cashcopilot_basic"
  title                = "Cashcopilot Basic"
  description          = "Cashcopilot Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.list", "storage.buckets.get", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
}

module "cashcopilot-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "cashcopilot_admin"
  title                = "Cashcopilot Admin"
  description          = "Cashcopilot Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.databaseReader", "roles/pubsub.viewer",  "roles/pubsub.publisher","roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
}
module "recon-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "recon_basic"
  title                = "Recon Basic"
  description          = "Recon Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.list", "storage.buckets.get", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list"] 
}

module "recon-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "recon_admin"
  title                = "Recon Admin"
  description          = "Recon Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.databaseReader", "roles/pubsub.viewer",  "roles/pubsub.publisher", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.fineGrainedAccessUser"]  
}

module "payments-basic" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "payments_basic"
  title                = "Payments Basic"
  description          = "Payments Basic Role"
  base_roles           = ["roles/logging.viewer", "roles/pubsub.viewer", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.list", "storage.buckets.get", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list"]
  excluded_permissions = ["resourcemanager.projects.list"] 
}
 
module "payments-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "payments_admin"
  title                = "Payments Admin"
  description          = "Payments Admin Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.databaseReader", "roles/pubsub.viewer", "roles/pubsub.publisher", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list"] 
  
}

module "engineering-oncall" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "engineering_oncall"
  title                = "Engineering Oncall"
  description          = "Engineering Oncall Role"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectViewer", "roles/spanner.databaseUser", "roles/pubsub.viewer", "roles/container.viewer", "roles/cloudtasks.viewer", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer"]
  members              = []
  permissions          = ["storage.buckets.list", "spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "storage.buckets.list", "storage.buckets.get", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "storage.buckets.list"]
  excluded_permissions = ["resourcemanager.projects.list"]
  
} 

module "zamp-admin" {
  source               = "../../modules/custom-iam-role"
  target_level         = "project"
  target_id            = var.project_id
  role_id              = "zamp_admin_role_id"
  title                = "zamp admin role id"
  description          = "zamp admin Role id"
  base_roles           = ["roles/logging.viewer", "roles/storage.objectAdmin", "roles/serviceusage.serviceUsageConsumer", "roles/iam.serviceAccountTokenCreator", "roles/spanner.admin", "roles/pubsub.admin", "roles/container.viewer", "roles/cloudtasks.admin", "roles/monitoring.viewer", "roles/monitoring.cloudConsoleIncidentViewer", "roles/privilegedaccessmanager.viewer", "roles/iap.tunnelResourceAccessor", "roles/bigquery.admin", "roles/dataflow.admin"]
  members              = []
  permissions          = ["spanner.instanceConfigs.get", "spanner.instanceConfigs.list", "spanner.instances.get", "spanner.instances.list", "spanner.instances.listEffectiveTags", "spanner.instances.listTagBindings", "spanner.databases.list", "monitoring.metricDescriptors.get", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "compute.instances.setMetadata","container.pods.getLogs"]
  excluded_permissions = ["resourcemanager.projects.list"]
  
} 

# module "composer" {
#   source = "../../modules/composer"
#   name                     = "zamp-prd-airflow"
#   region                   = "asia-southeast1"
#   service_account          = "518036456173-compute@developer.gserviceaccount.com"
#   image_version            = "composer-3-airflow-2.10.2-build.0"
#   enable_private_environment = true
#   network                   = "projects/production-351109/global/networks/zamp-prd-sg-vpc"
#   subnetwork                = "projects/production-351109/regions/asia-southeast1/subnetworks/zamp-prd-sg-vpc"
#   resilience_mode           = "STANDARD_RESILIENCE"
#   depends_on                = [module.vpc]
#   enable_web_server_plugins = true
# }
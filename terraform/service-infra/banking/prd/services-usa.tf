# module "banking_usa" {
#   source                = "../../../modules/services-usa/banking"
#   region                = var.region_usa
#   project_id            = var.project_id
#   project_prefix        = local.project_prefix_usa
#   spanner_instance_name = var.spanner_instance_name_usa
#   spanner_db_name       = "banking"
#   roles                 = ["roles/spanner.databaseUser", "roles/cloudtasks.taskRunner", "roles/cloudtasks.enqueuer", "roles/cloudtasks.viewer", "roles/iam.serviceAccountTokenCreator", "roles/cloudscheduler.admin"]
#   service_accounts      = local.k8s_service_accounts
#   # cloud_tasks           = local.cloud_tasks_eu
#    pubsub_topics         = local.pubsub_topics
#   buckets = [{
#     name       = "analytics-dataflow"
#     log_bucket = "${local.project_prefix_usa}-gcs-logging"
#     },
#     {
#       name       = "analytics"
#       log_bucket = "${local.project_prefix_usa}-gcs-logging"
#   }]
#   cors_origins = ["https://zamp.finance", "https://www.zamp.finance", "https://dashboard.zamp.finance", "https://www.dashboard.zamp.finance", "https://api.zamp.finance", "https://www.api.zamp.finance", "https://zamplabs.com", "https://www.zamplabs.com", "https://checkout.zamplabs.com", "https://www.checkout.zamplabs.com", "https://docs.zamplabs.com", "https://merchant.zamplabs.com", "https://www.docs.zamplabs.com", "https://www.merchant.zamplabs.com", "https://roma.zamplabs.com", "https://www.roma.zamplabs.com", "https://roma.zamp.finance", "https://www.roma.zamp.finance"]
# }


# module "payments-sdk_eu-dummy" {
#   source      = "../../../modules/services-eu/payments-sdk"
#   secrets     = ["payments-sdk-env"]
#   proj_prefix = local.project_prefix_eu
#   name_tag    = "payments-sdk-dummy"
#   static_domain = [
#     {
#       name   = "merchant-ui"
#       domain = "merchant.zamplabs.com"
#       routes = [{
#         host_path   = "/*"
#         backend     = "merchant-ui"
#         redirection = false
#         }
#       ]
#     },
#     {
#       name   = "payments-sdk"
#       domain = "checkout.zamplabs.com"
#       routes = [{
#         host_path   = "/*"
#         backend     = "payments-sdk"
#         redirection = false
#         }
#       ]
#     }
#   ]
# }


# module "roma_eu" {
#   source         = "../../../modules/services-eu/roma"
#   project_prefix = local.project_prefix_eu
# }

# module "banking_dashboard_eu_dummy" {
#   source         = "../../../modules/services-eu/banking-dashboard"
#   project_prefix = "${local.project_prefix_eu}-dummy"
#   static_domain = [
#     {
#       name   = "assets-eu-dummy"
#       domain = "assets-eu-dummy.zamp.finance"
#       routes = [{
#         host_path   = "/*"
#         backend     = "assets"
#         redirection = false
#         }
#       ]
#     },
#   ]
# }

# module "banking_dashboard_eu" {
#   source         = "../../../modules/services-eu/banking-dashboard"
#   project_prefix = local.project_prefix_eu
#   static_domain = [
#     {
#       name   = "assets"
#       domain = "assets.zamp.finance"
#       routes = [{
#         host_path   = "/*"
#         backend     = "assets"
#         redirection = false
#         }
#       ]
#     },
#   ]
# }

# module "bank_bridge_eu" {
#   source           = "../../../modules/services-eu/bank-bridge"
#   project_id       = var.project_id
#   region           = var.region_eu
#   project_prefix   = local.project_prefix_eu 
#   service_accounts = local.bank_bridge_k8s_service_accounts
#   pubsub_topics    = local.bank_bridge_pubsub_topics_eu
# }


#  module "internal_ops_dashboard_eu" {
#   static_hosting_domain = "ops.zamp.finance"
#   source                = "../../../modules/services/ui"
#   proj_prefix           = local.project_prefix_eu
#   name_tag              = "internal-ops-dashboard"
#   only_vpn_access       = false
#   vpn_connector_ip      = "34.77.51.201"
# }

# module "access_management_eu" {
#   source           = "../../../modules/services-eu/access-management"
#   project_id       = var.project_id
#   region           = var.region_eu
#   project_prefix   = local.project_prefix_eu
#   service_accounts = local.access_management_k8s_service_accounts
# }



# module "tms_dashboard_eu" {
#   source         = "../../../modules/services-eu/tms-dashboard"
#   project_prefix = local.project_prefix_eu
#     static_domain = [
#     {
#       name   = "tms-assets"
#       domain = "tms-assets.zamp.finance"
#       routes = [{
#         host_path   = "/*"
#         backend     = "tms-assets"
#         redirection = false
#         }
#       ]
#     },
#   ]
# }

module "hcp" {
  source           = "../../../modules/services/hcp"
  project_id       = var.project_id
  region           = var.region_usa
  project_prefix   = local.project_prefix_usa
  service_accounts = local.hcp_k8s_service_accounts
  # pubsub_topics    = local.hcp_pubsub_topics
}
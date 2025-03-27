# module "banking-usa" {
#   source                = "../../../modules/services-usa/banking"
#   region                = var.region
#   project_id            = var.project_id
#   project_prefix        = local.project_prefix_usa
#   spanner_instance_name = var.spanner_instance_name
#   spanner_db_name       = "banking"
#   roles                 = ["roles/spanner.databaseUser", "roles/cloudtasks.taskRunner", "roles/cloudtasks.enqueuer", "roles/cloudtasks.viewer", "roles/iam.serviceAccountTokenCreator","roles/cloudscheduler.admin","roles/secretmanager.viewer","roles/secretmanager.secretAccessor","roles/run.invoker","roles/bigquery.dataViewer","roles/bigquery.jobUser"]
#   service_accounts      = local.k8s_service_accounts
#   # cloud_tasks           = local.cloud_tasks
#   pubsub_topics         = local.pubsub_topics
#   cors_origins          = ["https://roma-stg.zamplabs.com", "https://checkout.stg.zamplabs.com", "https://www.checkout.stg.zamplabs.com","https://stg-dashboard.zamp.finance", "https://app-stg.zamp.finance", "https://stg-dashboard.roma.global", "https://ops.zamp.finance", "https://*.zampinvest.com"]
#   #cloudfunctions        = var.cloudfunctions
# }

# module "payments-sdk" {
#   source      = "../../../modules/services/payments-sdk"
#   secrets     = ["payments-sdk-env"]
#   proj_prefix = local.project_prefix
#   name_tag    = "payments-sdk"
#   static_domain = [
#     {
#       name   = "payments-ui-static"
#       domain = "merchant.stg.zamplabs.com"
#       routes = [{
#         host_path   = "/*"
#         backend     = "merchant-ui"
#         redirection = false
#         }
#       ]
#     },
#     {
#       name   = "payments-sdk"
#       domain = "checkout.stg.zamplabs.com"
#       routes = [{
#         host_path   = "/*"
#         backend     = "payments-sdk"
#         redirection = false
#         }
#       ]
#     }
#   ]
# }


# module "roma" {
#   source         = "../../../modules/services/roma"
#   project_prefix = local.project_prefix
# }
# module "banking_dashboard" {
#   source         = "../../../modules/services/banking-dashboard"
#   project_prefix = local.project_prefix
#   static_domain = [
#     {
#       name   = "assets"
#       domain = "assets-stg.zamp.finance"
#       routes = [{
#         host_path   = "/*"
#         backend     = "assets"
#         redirection = false
#         }
#       ]
#     },
#   ]
# }

# module "bank_bridge" {
#   source           = "../../../modules/services/bank-bridge"
#   project_id       = var.project_id
#   region           = var.region
#   project_prefix   = local.project_prefix
#   service_accounts = local.bank_bridge_k8s_service_accounts
#   pubsub_topics    = local.bank_bridge_pubsub_topics
# }


# module "internal_ops_dashboard" {
#   static_hosting_domain = "ops-stg.zamp.finance"
#   source                = "../../../modules/services/ui"
#   proj_prefix           = local.project_prefix
#   name_tag              = "internal-ops-dashboard"
#   only_vpn_access       = false
#   vpn_connector_ip      = "35.187.227.133"
# }

# module "access_management" {
#   source           = "../../../modules/services/access-management"
#   project_id       = var.project_id
#   region           = var.region
#   project_prefix   = local.project_prefix
#   service_accounts = local.access_management_k8s_service_accounts
# }

# module "tms_dashboard" {
#   source         = "../../../modules/services/tms-dashboard"
#   project_prefix = local.project_prefix
#     static_domain = [
#     {
#       name   = "tms-assets"
#       domain = "tms-assets-stg.zamp.finance"
#       routes = [{
#         host_path   = "/*"
#         backend     = "tms-assets"
#         redirection = false
#         }
#       ]
#     },
#   ]
# }

# module "alchemist" {
#   source           = "../../../modules/services/alchemist"
#   project_id       = var.project_id
#   region           = var.region
#   project_prefix   = local.project_prefix
#   service_accounts = local.alchemist_k8s_service_accounts
#   pubsub_topics    = local.alchemist_pubsub_topics
# }
module "banking" {
  source                = "../../../modules/services/banking"
  region                = var.region
  project_id            = var.project_id
  project_prefix        = local.project_prefix
  spanner_instance_name = var.spanner_instance_name
  spanner_db_name       = "banking"
  roles                 = ["roles/spanner.databaseUser", "roles/cloudtasks.taskRunner", "roles/cloudtasks.enqueuer", "roles/cloudtasks.viewer", "roles/iam.serviceAccountTokenCreator","roles/cloudscheduler.admin","roles/secretmanager.viewer","roles/secretmanager.secretAccessor","roles/run.invoker","roles/bigquery.dataViewer","roles/bigquery.jobUser"]
  service_accounts      = local.k8s_service_accounts
  cloud_tasks           = local.cloud_tasks
  pubsub_topics         = local.pubsub_topics
  buckets = [{
    name       = "analytics-dataflow"
    log_bucket = "${local.project_prefix}-gcs-logging"
    },
    {
      name       = "analytics"
      log_bucket = "${local.project_prefix}-gcs-logging"
  }]
  cors_origins = ["https://zamp.finance", "https://www.zamp.finance", "https://dashboard.zamp.finance", "https://www.dashboard.zamp.finance", "https://api.zamp.finance", "https://www.api.zamp.finance", "https://zamplabs.com", "https://www.zamplabs.com", "https://checkout.zamplabs.com", "https://www.checkout.zamplabs.com", "https://docs.zamplabs.com", "https://merchant.zamplabs.com", "https://www.docs.zamplabs.com", "https://www.merchant.zamplabs.com", "https://roma.zamplabs.com", "https://www.roma.zamplabs.com", "https://roma.zamp.finance", "https://www.roma.zamp.finance", "https://app.zamp.finance", "https://dashboard.roma.global", "https://ops.zamp.finance", "https://*.zampinvest.com", "https://local-tms.zamp.finance"]
   # cloudfunctions        = var.cloudfunctions

}


module "payments-sdk" {
  source      = "../../../modules/services/payments-sdk"
  secrets     = ["payments-sdk-env"]
  proj_prefix = local.project_prefix
  name_tag    = "payments-sdk"
  static_domain = [
    {
      name   = "merchant-ui"
      domain = "merchant.zamplabs.com"
      routes = [{
        host_path   = "/*"
        backend     = "merchant-ui"
        redirection = false
        }
      ]
    },
    {
      name   = "payments-sdk"
      domain = "checkout.zamplabs.com"
      routes = [{
        host_path   = "/*"
        backend     = "payments-sdk"
        redirection = false
        }
      ]
    }
  ]
}


module "roma" {
  source         = "../../../modules/services/roma"
  project_prefix = local.project_prefix
}
module "banking_dashboard" {
  source         = "../../../modules/services/banking-dashboard"
  project_prefix = local.project_prefix
  static_domain = [
    {
      name   = "assets"
      domain = "assets.zamp.finance"
      routes = [{
        host_path   = "/*"
        backend     = "assets"
        redirection = false
        }
      ]
    },
  ]
}

module "bank_bridge" {
  source           = "../../../modules/services/bank-bridge"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.bank_bridge_k8s_service_accounts
  pubsub_topics    = local.bank_bridge_pubsub_topics
}

module "internal_ops_dashboard" {
  static_hosting_domain = ["lumos.zamp.finance", "ops.zamp.finance"]
  source                = "../../../modules/services/ui-v2"
  proj_prefix           = local.project_prefix
  name_tag              = "internal-ops-dashboard"
  only_vpn_access       = false
  vpn_connector_ip      = "35.240.253.24"
}

module "access_management" {
  source           = "../../../modules/services/access-management"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.access_management_k8s_service_accounts
}

module "tms_dashboard" {
  source         = "../../../modules/services/tms-dashboard"
  project_prefix = local.project_prefix
    static_domain = [
    {
      name   = "tms-assets"
      domain = "tms-assets.zamp.finance"
      routes = [{
        host_path   = "/*"
        backend     = "tms-assets"
        redirection = false
        }
      ]
    },
  ]
}

module "alchemist" {
  source           = "../../../modules/services/alchemist"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.alchemist_k8s_service_accounts
  pubsub_topics    = local.alchemist_pubsub_topics
}

module "herm" {
  source           = "../../../modules/services/herm"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.herm_k8s_service_accounts
  cors_origins     = ["http://localhost:3000", "http://localhost:4000", "https://*.zamp.finance", "https://*.roma.global", "https://*.zampinvest.com" , "https://127.0.0.1:8000"]

}

module "worklfow" {
  source           = "../../../modules/services/workflow"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.workflow_k8s_service_accounts
}

# module "hcp" {
#   source           = "../../../modules/services/hcp"
#   project_id       = var.project_id
#   region           = var.region
#   project_prefix   = local.project_prefix
#   service_accounts = local.hcp_k8s_service_accounts
#   pubsub_topics    = local.hcp_pubsub_topics
# }

module "pantheon" {
  source           = "../../../modules/services/pantheon"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.pantheon_k8s_service_accounts
}


module "herm_dashboard" {
  source         = "../../../modules/services/herm-dashboard"
  project_prefix = local.project_prefix
  static_domain = [
    {
      name   = "herm-assets"
      domain = "herm-assets.zamp.ai"
      routes = [{
        host_path   = "/*"
        backend     = "herm-assets"
        redirection = false
        }
      ]
    },
  ]
}

module "windmill" {
  source           = "../../../modules/services/windmill"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.windmill_k8s_service_accounts
}

module "composer" {
  source           = "../../../modules/services/composer"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.composer_k8s_service_accounts
}

# resource "google_privileged_access_manager_entitlement" "basic_entitlement" {
#   entitlement_id         = "basic_entitlement"
#   location               = "global"
#   max_request_duration   = "43200s"
#   parent                 = "projects/production-351109"
#   requester_justification_config {    
#     unstructured {}
#   }
#   eligible_users {
#     principals = [
#       "group:engineering@zamp.finance"
#     ]
#   }
#   privileged_access {
#     gcp_iam_access {
#       role_bindings {
#         role                 = ["roles/bigquery.dataViewer","roles/bigquery.jobUser"]
#         condition_expression = local.basic_expression
#       }
#       resource       = "//cloudresourcemanager.googleapis.com/projects/production-351109"
#       resource_type  = "cloudresourcemanager.googleapis.com/Project"
#     }
#   }
#   additional_notification_targets {
#     admin_email_recipients = [
#       "atharva@zamp.finance","nipun@zamp.finance"
#     ]
#     # requester_email_recipients = [
#     #   "requester@example.com"
#     # ]
#   }
#   approval_workflow {
#     manual_approvals {
#       require_approver_justification = false
#       steps {
#         approvals_needed = 1
#         approver_email_recipients = [
#           "approver@example.com"
#         ]
#         approvers {
#           principals = [
#             "atharva@zamp.finance","nipun@zamp.finance"
#           ]
#         }
#       }
#     }
#   }
# }


# module "keda" {
#   source           = "../../../modules/services/keda"
#   project_id       = var.project_id
#   region           = var.region
#   project_prefix   = local.project_prefix
#   service_accounts = local.keda_k8s_service_accounts
# }

module "connectivity_platform" {
  source           = "../../../modules/services/connectivity-platform"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.connectivity_k8s_service_accounts
}


module "zamp_ap_agent" {
  source           = "../../../modules/services/zamp-ap-agent"
  project_id       = var.project_id
  region           = var.region
  project_prefix   = local.project_prefix
  service_accounts = local.ap_agent_k8s_service_accounts
}
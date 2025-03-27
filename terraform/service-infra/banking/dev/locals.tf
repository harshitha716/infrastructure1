locals {
  k8s_service_accounts = fileexists("${path.module}/config/sa.yaml") ? concat(yamldecode(file("${path.module}/../config/sa.yaml")), yamldecode(file("${path.module}/config/sa.yaml"))) : yamldecode(file("${path.module}/../config/sa.yaml"))
  pubsub_topics        = fileexists("${path.module}/config/topics.yaml") ? concat(yamldecode(file("${path.module}/../config/topics.yaml")), yamldecode(file("${path.module}/../config/topics.yaml"))) : yamldecode(file("${path.module}/../config/topics.yaml"))
  cloud_tasks          = fileexists("${path.module}/config/cloudtask.yaml") ? concat(yamldecode(templatefile("${path.module}/../config/cloudtask.yaml", { region = var.region })), yamldecode(templatefile("${path.module}/config/cloudtask.yaml", { region = var.region }))) : yamldecode(templatefile("${path.module}/../config/cloudtask.yaml", { region = var.region }))
  # basic_tables     = yamldecode(file("${path.module}/../config/basic-tables.yaml"))["tables"]
  # sensitive_tables = yamldecode(file("${path.module}/../config/sensitive-tables.yaml"))["tables"]
  # pii_tables       = yamldecode(file("${path.module}/../config/pii-tables.yaml"))["tables"]
}


# locals {
#   basic_condition = join(" || ", [for table in local.basic_tables : "resource.name == \"${table}\""])
#   sensitive_condition = join(" || ", [for table in local.sensitive_tables : "resource.name == \"${table}\""])
#   pii_condition = join(" || ", [for table in local.pii_tables : "resource.name == \"${table}\""])
# }

# locals {
#   basic_expression = "resource.type == \"bigquery.googleapis.com/Table\" && (${local.basic_condition})"
#   sensitive_expression = "resource.type == \"bigquery.googleapis.com/Table\" && (${local.sensitive_condition})"
#   pii_expression = "resource.type == \"bigquery.googleapis.com/Table\" && (${local.pii_condition})"
# }

locals {
  bank_bridge_k8s_service_accounts = [
    {
      k8s_service_account_name      = "zamp-bank-bridge-svc"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-payout-transaction-consumer"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-bank-statements-consumer"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-gib-uae-payouts-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-mashreq-uae-payouts-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-mashreq-egy-payouts-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-alrajhi-ksa-payouts-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-gib-uae-source-files-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-sync-transactions-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-sync-real-time-transactions-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-partner-files-consumer"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-drive-file-sourcing-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-seed-dummy-transactions-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-email-data-ingestion-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-sab-ksa-payouts-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-seed-daily-dummy-transactions-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-sync-transactions-manually-job"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-bank-accounts-worker"
      k8s_service_account_namespace = "zamp"
    },
    {
      k8s_service_account_name      = "zamp-bank-bridge-payouts-processing-worker"
      k8s_service_account_namespace = "zamp"
    }
  ]

  bank_bridge_pubsub_topics = [
    {
      name                         = "payout-transaction"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false 
      subscriptions                = ["payout-transaction"]
    },
    {
      name                         = "bank-bridge-bank-statements"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false 
      subscriptions                = ["bank-bridge-bank-statements"]
    },
    {
      name                         = "bank-bridge-payout-transactions-ops"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false 
      subscriptions                = ["bank-bridge-payout-transactions-ops"]
    },
    {
      name                         = "bank-bridge-webhook"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false
      subscriptions                = ["bank-bridge-webhook"]
    },
    {
      name                         = "bank-bridge-file-sourcing"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false
      subscriptions                = ["bank-bridge-file-sourcing"]
    }                 
  ]
    access_management_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-access-management-svc"
    k8s_service_account_namespace = "zamp"
  }]
  alchemist_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-alchemist-svc"
    k8s_service_account_namespace = "zamp"
  },
  {
     k8s_service_account_name      = "zamp-ops-svc"
    k8s_service_account_namespace = "zamp"
  },
  {
     k8s_service_account_name      = "zamp-alchemist-doordash-braintree-forecast"
    k8s_service_account_namespace = "zamp"
  },
  {
     k8s_service_account_name      = "zamp-alchemist-file-monitoring-forecast"
    k8s_service_account_namespace = "zamp"
  },
  {
     k8s_service_account_name      = "zamp-alchemist-consumer"
    k8s_service_account_namespace = "zamp"
  }]

  herm_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-herm-svc"
    k8s_service_account_namespace = "herm"
  },
  ]

    workflow_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-workflow-platform-svc"
    k8s_service_account_namespace = "workflow"
  },
  {
    k8s_service_account_name      = "zamp-workflow-platform-worker"
    k8s_service_account_namespace = "workflow"
  }]

 hcp_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-hcp-auth-auth"
    k8s_service_account_namespace = "hcp"
  },
  {
    k8s_service_account_name      = "zamp-hcp-api-api"
    k8s_service_account_namespace = "hcp"
  },
  {
    k8s_service_account_name      = "zamp-hcp-datasets-datasets"
    k8s_service_account_namespace = "hcp"
  },
    {
    k8s_service_account_name      = "zamp-hcp-api-worker-default-api-worker-default"
    k8s_service_account_namespace = "hcp"
  }]

  hcp_pubsub_topics = [
  {
    name                         = "keda"
    dlq_enabled                  = true
    ack_deadline_seconds         = 600
    enable_message_ordering      = true
    enable_exactly_once_delivery = true
    retry_enabled                = false 
    subscriptions                = ["keda"]
  }]

 windmill_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-banking-windmill"
    k8s_service_account_namespace = "windmill"
  }]

    selenium_k8s_service_accounts = [{
    k8s_service_account_name      = "selenium-grid-selenium-serviceaccount"
    k8s_service_account_namespace = "selenium-grid"
  }]

   composer_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-browser-automation"
    k8s_service_account_namespace = "composer"
  }]
   keda_k8s_service_accounts = [{
    k8s_service_account_name      = "keda-operator"
    k8s_service_account_namespace = "keda"
  }]

    pantheon_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-pantheon-svc"
    k8s_service_account_namespace = "pantheon"
  },
  {
    k8s_service_account_name      = "zamp-pantheon-svc-svc"
    k8s_service_account_namespace = "pantheon"
  },
  {
    k8s_service_account_name      = "zamp-pantheon-svc-worker"
    k8s_service_account_namespace = "pantheon"
  }]

  connectivity_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-connectivity-api-api"
    k8s_service_account_namespace = "connectivity"
  },
  {
    k8s_service_account_name      = "zamp-connectivity-worker-worker"
    k8s_service_account_namespace = "connectivity"
  }]

  ap_agent_k8s_service_accounts = [{
    k8s_service_account_name      = "zamp-ap-agent"
    k8s_service_account_namespace = "zamp-ap-agent"
  }]
    alchemist_pubsub_topics = [
    {
      name                         = "alchemist-test-topic"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false 
      subscriptions                = ["alchemist-test-topic"]
    },
    {
      name                         = "file-processing-results"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false 
      subscriptions                = ["file-processing-results"]
    },
    {
      name                         = "file-processing"
      dlq_enabled                  = true
      ack_deadline_seconds         = 600
      enable_message_ordering      = true
      enable_exactly_once_delivery = true
      retry_enabled                = false 
      subscriptions                = ["file-processing","banking-file-processing"]
    },
    ]
    airbyte_k8s_service_accounts = [ 
   {
      k8s_service_account_name      = "default"
      k8s_service_account_namespace = "airbyte"
    },
    {
      k8s_service_account_name      = "airbyte-admin"
      k8s_service_account_namespace = "airbyte"
    },  
    ]
 }
data "google_project" "project" {
}

module "banking_dataset" {
  source         = "../../modules/bigquery"
  dataset_id     = "banking"
  name           = "banking"
  description    = "dataset for spanner database banking"
  location       = var.region
  project_prefix = local.project_prefix
  labels = {
    env = "prd"
  }
}

module "storage" {
  source      = "../../modules/storage"
  proj_prefix = local.project_prefix
  storage     = local.buckets
  location    = var.region
}

module "kms_dataflow" {
  source          = "../../modules/kms"
  key_ring_name   = "${local.project_prefix}-streaming-dataflow"
  location        = var.region
  crypto_key_name = "${local.project_prefix}-streaming-dataflow"
  iam_member      = local.kms_iam_member
}

module "dataflow_streaming_job" {
  depends_on = [
    module.storage,
    module.kms_dataflow
  ]
  source               = "../../modules/dataflow"
  enable_streaming_job = var.enable_streaming_job
  name                 = "${local.project_prefix}-banking-streaming-job-2"
  project_prefix       = local.project_prefix
  project_id           = var.project_id
  region               = var.region
  parameters = {
    numWorkers                         = 1
    spannerInstanceId                  = "${local.project_prefix}-cloudspanner"
    spannerDatabase                    = "banking"
    spannerMetadataInstanceId          = "${local.project_prefix}-cloudspanner"
    spannerMetadataDatabase            = "banking-metadata"
    spannerChangeStreamName            = "DataWarehouseStream"
    bigQueryDataset                    = "banking"
    rpcPriority                        = "HIGH"
    dlqRetryMinutes                    = 10
    maxNumWorkers                      = 50
    experiments                        = "enable_stackdriver_agent_metrics"
    bigQueryChangelogTableNameTemplate = "{_metadata_spanner_table_name}_Raw"
    enableStreamingEngine              = true
    dataflowKmsKey                     = module.kms_dataflow.crypto_key_id
    stagingLocation                    = "gs://${local.project_prefix}-data-warehouse-staging/staging"
    tempLocation                       = "gs://${local.project_prefix}-data-warehouse-staging/temp"
    deadLetterQueueDirectory           = "gs://${local.project_prefix}-data-warehouse-staging/dlq"
    network                            = "${local.project_prefix}-vpc"
    autoscalingAlgorithm               = "THROUGHPUT_BASED"
    startTimestamp                     = timeadd(timestamp(), "-6h")
    workerMachineType                  = "n1-standard-1"
  }
}

module "redash" {
  for_each   = var.enable_redash ? toset(["1"]) : toset([])
  depends_on = [module.banking_dataset]
  source     = "../../modules/redash"
  project_id = var.project_id
  tables     = ["AccountBalanceLogs", "Accounts", "ApprovalRequests", "B2BUserInvitations", "B2bUsers", "B2bUsersConfigurations", "Balances", "BalancesHistory", "Beneficiaries", "BillingAccount", "BillingAccountBillingCapabilityMapping", "BillingCapability", "BillingCapabilityEntityMapping", "BillingTransactions", "BulkPayouts", "BurnerWallet", "CampaignDetails", "Campaigns", "CardConfigs", "CardConfigsHistory", "CardDetails", "Cards", "ChargeAccounts", "ConsentCapability", "Corridors", "CounterParties", "Currencies", "CurrencyDetails", "CurrencyPartners", "CurrencyPartnersMappings", "CustomPaymentLinks", "CustomPortfolioAssetMappings", "DashboardUsers", "DepositAccounts", "Discounts", "Documents", "Entities", "EntityConfigurations", "EphemeralWallets", "ERPConnectionSecrets", "ERPEntityMapping", "Events", "FxRateHistory", "GlobalCurrencies", "HolidayCalender", "IdempotencyKeys", "InternalTransactions", "Investment", "InvestmentAsset", "InvestmentAssetConfig", "InvestmentAssetHistory", "InvestmentDocuments", "InvestmentPortfolio", "InvestmentPortfolioAssetMappings", "Kyb", "KybDetails", "Ledger", "Ledgers", "MerchantConfigurations", "MerchantCorridorConfigs", "MerchantCorridorMappings", "Merchants", "MerchantTnC", "NetworkDetails", "NotificationChannels", "Notifications", "PartnerBeneficiaryMappings", "PaymentOptionCurrencyMerchantMappings", "PaymentOptions", "Payments", "PaymentSessions", "PayoutRequests", "PayoutSessions", "PricingTierCapabilityMapping", "PricingTiers", "QRGateways", "Questionnaire", "QuestionnaireQuestionsMapping", "Questions", "QuotePartnerMappings", "Quotes", "ReferentialUUIDMappings", "TnC", "TransactionAndTypeMappings", "TransactionHashes", "Transactions", "TreasuryConfigurations", "UnRealisedLedgers", "UserCustomPortfolio", "UserMerchantRelations", "UserQuestionnaireResponses", "Users", "UserWallets", "Vaults", "WireTransactions", "Wishlist", "Roles", "Permissions", "RoleConfigurations", "UserRoleMappings", "ShareableForm", "ShareableFormConfigurations", "KybPartnerMapping", "PolicyConfigurations", "ApprovalRequestsV2", "PolicyResults", "Policies", "SmbBankingMetricsWeekly", "SmbBankingWeeklyOverview", "SmbTransactionRequests", "BankingPartners", "BankingPartnerConnections", "BankingPartnerConnectionConfigs", "BankingPartnerUsers", "BankAccounts", "BankStatements", "BankAccountBalances", "EntityOpenBankingConnectionMappings", "CashOpsTransactionViews", "SmbBankingEntityWiseDailyOverview", "SmbBankingDailyOverview", "SmbBankingMetricsDaily", "TransactionRequests", "EventsV2", "BankFiles", "PayoutQueue", "Workflows", "WorkflowConfigurations", "Tags", "TagGroups", "TagGroupConfigurations", "ResourceTagMappings", "Webhooks", "CashOpsTransactionsView", "CashOpsBankTransactions", "Rules", "AuditLogs", "AuditLogResourceMappings", "Templates", "TemplateMerchantMappings", "FileImports", "AnalyticsHistory", "Analytics", "UserWidgets", "CurrencyExchangeHistory", "RecommendedResourceTagMappings", "Kyc", "WhitelistedResources", "KycDetails", "SpreadsheetWorkbooks", "SpreadsheetRows", "SpreadsheetColumns", "SpreadsheetCells", "SpreadsheetCellHistories", "MerchantForecastingConfiguration", "BeneficiaryDocumentMapping", "ReconFileImportResults", "Dashboards", "DashboardUserMappings", "DashboardConfigurations", "PortfolioDetailsHistory", "PortfolioDetailsInvestmentAssetMappings", "ResourceCredentials", "InvestmentWithdrawalConfigurations", "InvestmentWithdrawalRequests", "EntityPortfolioMapping", "PortfolioDetails", "ParentPartnerFilesConfigurations", "ParentPartnerFiles", "Depositors", "BulkActions", "BulkActionsTasks", "FundsInTransit", "FundsInTransitConfigurations", "BeneficiaryConfigurations", "PayoutTemplates", "EntityCorridorTemplateMappings", "CorridorPayoutTemplateMappings", "EntityCorridorConfigs", "PartnerAccountMappings", "PartnerTransactionRequests","FundsInTransitAggregations","SuperMerchantSecrets","SuperMerchants", "InternalSettlements"]
  dataset_id = "banking"
  region     = var.region
  network    = "${local.project_prefix}-vpc"
}

module "metadata_db" {
  source                = "../../modules/spanner-db"
  spanner_db_name       = "banking-metadata"
  spanner_instance_name = "${local.project_prefix}-cloudspanner"
}

locals {
  buckets = [
    {
      name       = "data-warehouse"
      log_bucket = "zamp-prd-sg-gcs-logging"
    },
    {
      name       = "data-warehouse-staging"
      log_bucket = "zamp-prd-sg-gcs-logging"
    },
        {
      name       = "data-warehouse-tms"
      log_bucket = "zamp-prd-sg-gcs-logging-tms"
    },
    {
      name       = "data-warehouse-staging-tms"
      log_bucket = "zamp-prd-sg-gcs-logging-tms"
    }
  ]
  kms_iam_member = "serviceAccount:service-${data.google_project.project.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
}


resource "google_service_account" "basic_redash_sa" {
  account_id   = "basic-redash-all-tables-sa"
  display_name = "Redash Basic All Tables Service Account"
}

resource "google_service_account" "sensitive_redash_sa" {
  account_id   = "sensitive-redash-all-tables-sa"
  display_name = "Redash Sensitive All Tables Service Account"
}

resource "google_service_account" "pii_redash_sa" {
  account_id   = "pii-redash-all-tables-sa"
  display_name = "Redash PII All Tables Service Account"
}

resource "google_project_iam_member" "basic_redash_sa_bq_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.basic_redash_sa.email}"
}
resource "google_project_iam_member" "basic_redash_sa_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.basic_redash_sa.email}"
}
resource "google_project_iam_member" "sensitive_redash_sa_bq_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.sensitive_redash_sa.email}"
}
resource "google_project_iam_member" "sensitive_redash_sa_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.sensitive_redash_sa.email}"
}
resource "google_project_iam_member" "pii_redash_sa_bq_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.pii_redash_sa.email}"
}
resource "google_project_iam_member" "pii_redash_sa_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.pii_redash_sa.email}"
}

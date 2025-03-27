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
    env = "dev"
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
  name                 = "${local.project_prefix}-banking-streaming-job"
  project_id           = var.project_id
  region               = var.region
  project_prefix       = local.project_prefix
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
    maxNumWorkers                      = 3
    experiments                        = "enable_stackdriver_agent_metrics"
    bigQueryChangelogTableNameTemplate = "{_metadata_spanner_table_name}_Raw"
    enableStreamingEngine              = true
    dataflowKmsKey                     = module.kms_dataflow.crypto_key_id
    stagingLocation                    = "gs://${local.project_prefix}-data-warehouse-staging/staging"
    tempLocation                       = "gs://${local.project_prefix}-data-warehouse-staging/temp"
    deadLetterQueueDirectory           = "gs://${local.project_prefix}-data-warehouse-staging/dlq"
    network                            = "${local.project_prefix}-vpc"
    autoscalingAlgorithm               = "THROUGHPUT_BASED"
    startTimestamp                     = timeadd(timestamp(), "-2h")
    workerMachineType                  = "n1-standard-1"
  }
}

module "redash" {
  source     = "../../modules/redash"
  project_id = var.project_id
  tables     = ["AccountBalanceLogs", "Accounts", "ApprovalRequests", "B2BUserInvitations", "B2bUsers", "B2bUsersConfigurations", "Balances", "BalancesHistory", "Beneficiaries", "BillingAccount", "BillingAccountBillingCapabilityMapping", "BillingCapability", "BillingCapabilityEntityMapping", "BillingTransactions", "BulkPayouts", "BurnerWallet", "CampaignDetails", "Campaigns", "CardConfigs", "CardConfigsHistory", "CardDetails", "Cards", "ChargeAccounts", "ConsentCapability", "Corridors", "CounterParties", "Currencies", "CurrencyDetails", "CurrencyPartners", "CurrencyPartnersMappings", "CustomPaymentLinks", "CustomPortfolioAssetMappings", "DashboardUsers", "DepositAccounts", "Discounts", "Documents", "Entities", "EntityConfigurations", "EphemeralWallets", "ERPConnectionSecrets", "ERPEntityMapping", "Events", "FxRateHistory", "GlobalCurrencies", "HolidayCalender", "IdempotencyKeys", "InternalTransactions", "Investment", "InvestmentAsset", "InvestmentAssetConfig", "InvestmentAssetHistory", "InvestmentDocuments", "InvestmentPortfolio", "InvestmentPortfolioAssetMappings", "Kyb", "KybDetails", "Ledger", "Ledgers", "MerchantConfigurations", "MerchantCorridorConfigs", "MerchantCorridorMappings", "Merchants", "MerchantTnC", "NetworkDetails", "NotificationChannels", "Notifications", "PartnerBeneficiaryMappings", "PaymentOptionCurrencyMerchantMappings", "PaymentOptions", "Payments", "PaymentSessions", "PayoutRequests", "PayoutSessions", "PricingTierCapabilityMapping", "PricingTiers", "QRGateways", "Questionnaire", "QuestionnaireQuestionsMapping", "Questions", "QuotePartnerMappings", "Quotes", "ReferentialUUIDMappings", "TnC", "TransactionAndTypeMappings", "TransactionHashes", "Transactions", "TreasuryConfigurations", "UnRealisedLedgers", "UserCustomPortfolio", "UserMerchantRelations", "UserQuestionnaireResponses", "Users", "UserWallets", "Vaults", "WireTransactions", "Wishlist", "Roles", "Permissions", "RoleConfigurations", "UserRoleMappings", "ShareableForm", "ShareableFormConfigurations", "PartnerTransactionRequests", "InternalSettlements"]
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
      log_bucket = "zamp-dev-sg-gcs-logging"
    },
    {
      name       = "data-warehouse-staging"
      log_bucket = "zamp-dev-sg-gcs-logging"
    }
  ]
  kms_iam_member = "serviceAccount:service-${data.google_project.project.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
}


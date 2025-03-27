data "google_project" "project_eu" {
}

# module "banking_dataset_eu" {
#   source         = "../../modules/bigquery-eu"
#   dataset_id     = "banking_eu"
#   name           = "banking_eu"
#   description    = "dataset for spanner database banking"
#   location       = var.region_eu
#   project_prefix = local.project_prefix_eu
#   labels = {
#     env = "prd"
#   }
# }

# module "storage_eu" {
#   source      = "../../modules/storage-eu"
#   proj_prefix = local.project_prefix_eu
#   storage     = local.buckets_eu
#   location    = var.region_eu
# }

# module "kms_dataflow_eu" {
#   source          = "../../modules/kms"
#   key_ring_name   = "${local.project_prefix_eu}-streaming-dataflow-v2"
#   location        = var.region_eu
#   crypto_key_name = "${local.project_prefix}-streaming-dataflow-v2"
#   iam_member      = local.kms_iam_member_eu
# }


# module "dataflow_streaming_job_eu" {
#   depends_on = [
#     module.storage,
#     module.kms_dataflow
#   ]
#   source               = "../../modules/dataflow"
#   enable_streaming_job = var.enable_streaming_job
#   name                 = "${local.project_prefix}-banking-streaming-job"
#   project_prefix       = local.project_prefix_eu
#   project_id           = var.project_id
#   region               = var.region_eu
#   parameters = {
#     numWorkers                         = 1
#     spannerInstanceId                  = "${local.project_prefix_eu}-cloudspanner"
#     spannerDatabase                    = "banking"
#     spannerMetadataInstanceId          = "${local.project_prefix_eu}-cloudspanner"
#     spannerMetadataDatabase            = "banking-metadata"
#     spannerChangeStreamName            = "DataWarehouseStream"
#     bigQueryDataset                    = "banking"
#     rpcPriority                        = "HIGH"
#     dlqRetryMinutes                    = 10
#     maxNumWorkers                      = 3
#     experiments                        = "enable_stackdriver_agent_metrics"
#     bigQueryChangelogTableNameTemplate = "{_metadata_spanner_table_name}_Raw"
#     enableStreamingEngine              = true
#     dataflowKmsKey                     = module.kms_dataflow.crypto_key_id
#     stagingLocation                    = "gs://${local.project_prefix_eu}-data-warehouse-staging/staging"
#     tempLocation                       = "gs://${local.project_prefix_eu}-data-warehouse-staging/temp"
#     deadLetterQueueDirectory           = "gs://${local.project_prefix_eu}-data-warehouse-staging/dlq"
#     network                            = "${local.project_prefix_eu}-vpc"
#     autoscalingAlgorithm               = "THROUGHPUT_BASED"
#     startTimestamp                     = timeadd(timestamp(), "-1h")
#     workerMachineType                  = "n1-standard-1"
#   }
# }

# module "redash_eu" {
#   for_each   = var.enable_redash ? toset(["1"]) : toset([])
#   depends_on = [module.banking_dataset_eu]
#   source     = "../../modules/redash"
#   project_id = var.project_id
#   tables     = ["AccountBalanceLogs", "Accounts", "ApprovalRequests", "B2BUserInvitations", "B2bUsers", "B2bUsersConfigurations", "Balances", "BalancesHistory", "Beneficiaries", "BillingAccount", "BillingAccountBillingCapabilityMapping", "BillingCapability", "BillingCapabilityEntityMapping", "BillingTransactions", "BulkPayouts", "BurnerWallet", "CampaignDetails", "Campaigns", "CardConfigs", "CardConfigsHistory", "CardDetails", "Cards", "ChargeAccounts", "ConsentCapability", "Corridors", "CounterParties", "Currencies", "CurrencyDetails", "CurrencyPartners", "CurrencyPartnersMappings", "CustomPaymentLinks", "CustomPortfolioAssetMappings", "DashboardUsers", "DepositAccounts", "Discounts", "Documents", "Entities", "EntityConfigurations", "EphemeralWallets", "ERPConnectionSecrets", "ERPEntityMapping", "Events", "FxRateHistory", "GlobalCurrencies", "HolidayCalender", "IdempotencyKeys", "InternalTransactions", "Investment", "InvestmentAsset", "InvestmentAssetConfig", "InvestmentAssetHistory", "InvestmentDocuments", "InvestmentPortfolio", "InvestmentPortfolioAssetMappings", "Kyb", "KybDetails", "Ledger", "Ledgers", "MerchantConfigurations", "MerchantCorridorConfigs", "MerchantCorridorMappings", "Merchants", "MerchantTnC", "NetworkDetails", "NotificationChannels", "Notifications", "PartnerBeneficiaryMappings", "PaymentOptionCurrencyMerchantMappings", "PaymentOptions", "Payments", "PaymentSessions", "PayoutRequests", "PayoutSessions", "PricingTierCapabilityMapping", "PricingTiers", "QRGateways", "Questionnaire", "QuestionnaireQuestionsMapping", "Questions", "QuotePartnerMappings", "Quotes", "ReferentialUUIDMappings", "TnC", "TransactionAndTypeMappings", "TransactionHashes", "Transactions", "TreasuryConfigurations", "UnRealisedLedgers", "UserCustomPortfolio", "UserMerchantRelations", "UserQuestionnaireResponses", "Users", "UserWallets", "Vaults", "WireTransactions", "Wishlist", "Roles", "Permissions", "RoleConfigurations", "UserRoleMappings", "ShareableForm", "ShareableFormConfigurations", "KybPartnerMapping", "PolicyConfigurations", "ApprovalRequestsV2", "PolicyResults", "Policies", "SmbBankingMetricsWeekly", "SmbBankingWeeklyOverview", "SmbTransactionRequests", "BankingPartners", "BankingPartnerConnections", "BankingPartnerConnectionConfigs", "BankingPartnerUsers", "BankAccounts", "BankStatements", "BankAccountBalances", "EntityOpenBankingConnectionMappings", "CashOpsTransactionViews", "SmbBankingEntityWiseDailyOverview", "SmbBankingDailyOverview", "SmbBankingMetricsDaily"]
#   dataset_id = "banking"
#   region     = var.region_eu
#   network    = "${local.project_prefix_eu}-vpc"
# }

# module "metadata_db_eu" {
#   source                = "../../modules/spanner-db"
#   spanner_db_name       = "banking-metadata"
#   spanner_instance_name = "${local.project_prefix_eu}-cloudspanner"
# }

# locals {
#   buckets_eu = [
#     {
#       name       = "data-warehouse"
#       log_bucket = "zamp-prd-eu-gcs-logging"
#     },
#     {
#       name       = "data-warehouse-staging"
#       log_bucket = "zamp-prd-eu-gcs-logging"
#     }
#   ]
#   kms_iam_member_eu = "serviceAccount:service-${data.google_project.project.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
# }
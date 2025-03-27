module "vpc" {
  source                            = "../../aws-modules/NetworkingV1/modules/vpc"
  region                            = var.region
  environment                       = var.environment
  vpcs                              = var.vpcs
}
module "subnet" {
  # providers = {
  #   aws.databricks = aws.databricks
  # }
  source                            = "../../aws-modules/NetworkingV1/modules/subnets"
  vpc_id                            = module.vpc.vpc_ids[0]
  vpc_cidr                          = module.vpc.vpc_cidr[0]
  internet_gateway_id               = module.vpc.internet_gateway_ids[0]
  region                            = var.region
  environment                       = var.environment
  nat_gateways                      = var.nat_gateways
  private_subnets                   = var.private_subnets
  public_subnets                    = var.public_subnets
  private_subnet_route_tables       = var.private_subnet_route_tables
  public_subnet_route_tables        = var.public_subnet_route_tables
  databricks_vpc_peering_connection = var.databricks_vpc_peering_connection
 
 }

module "eks" {
  source                   = "../../aws-modules/eks"
  cluster_name             = var.cluster_name
  vpc_id                   = module.vpc.vpc_ids[0]
  private_subnet_ids       = module.subnet.private_subnet_ids

  public_subnet_ids        = module.subnet.public_subnet_ids
  # openvpn_cidrs            = var.openvpn_cidrs
  kubernetes_version       = var.kubernetes_version
  worker_nodes_group_list  = var.worker_nodes_group_list
  worker_nodes_group_list_public  = var.worker_nodes_group_list_public
  environment              = var.environment
  tags                     = var.tags
  controller_node_group = var.controller_node_group
  zookeeper_node_group  = var.zookeeper_node_group
  broker_node_group     = var.broker_node_group
  minion_node_group     = var.minion_node_group
  core_node_group       = var.core_node_group
  server_node_group = var.server_node_group
}

# module "bastion" {
#   source             = "../../aws-modules/bastion"
#   cluster_name       = module.eks.cluster_name
#   vpc_id             = module.vpc.vpc_ids[0]
#   public_subnet_ids  = [module.subnet.public_subnet_ids[0]]
#   tags               = var.tags
#   ssh_key_name       = var.bastion_ssh_key_name
#   allowed_cidr       = var.allowed_cidr
#   bastion_instance_type = "t2.medium"  
# }

module "pinot_s3_deepstore-poc" {
  source = "../../aws-modules/pinot-s3-deepstore-poc"

  s3_bucket_name         = "zamp-prd-pinot-deep-store-bucket-poc"
  eks_oidc_provider_url  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  k8s_namespace          = "pinot"
  k8s_service_account_name = "pinot-s3-access"
}

module "pinot_s3_deepstore" {
  source = "../../aws-modules/pinot-s3-deepstore"

  s3_bucket_name         = "zamp-prd-pinot-deep-store-bucket"
  eks_oidc_provider_url  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  k8s_namespace          = "pinot"
  k8s_service_account_name = "pinot"
}

module "aws_load_balancer_controller" {
  source = "../../aws-modules/AwsLoadbalancerController"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  tags              = var.tags
}

module "snowflake_s3_iam" {
  source = "../../aws-modules/snowflake-integration"
  s3_bucket_name       = "zamp-prd-file-imports"
}

module "msk_cluster" {
  source = "../../aws-modules/Msk"

  cluster_name           = "zamp-prd-kafka-cluster"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3
  instance_type          = "express.m7g.xlarge"
  vpc_id                 = module.vpc.vpc_ids[0]
  private_subnet_ids     = [
    "subnet-0b9273491cf4c1e37",  # ID for zamp1-us-east-1a-1
    "subnet-08b5636ba5aa2c889",  # ID for zamp1-us-east-1b-1
    "subnet-0197727ecd07a7959"   # ID for zamp1-us-east-1c-1
  ]
  allowed_cidr_blocks    = [
    module.vpc.vpc_cidr[0],
  ]
  kms_key_arn            = aws_kms_key.kafka_encryption_key.arn
  # log_retention_days     = 3

  tags = var.tags
}


resource "aws_kms_key" "kafka_encryption_key" {
  description = "KMS key for Kafka data encryption"
  enable_key_rotation = true

  tags = var.tags
}

module "observability_iam_roles" {
  source = "../../aws-modules/ObservabilityIAMRoles"

  s3_bucket_name             = "zamp-prd-loki-logs"
  eks_oidc_provider_url      = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  k8s_namespace              = "monitoring"
  prometheus_service_account = "prometheus"
  loki_service_account       = "loki"
  fluent_bit_service_account = "fluent-bit"
  tags                       = var.tags
}
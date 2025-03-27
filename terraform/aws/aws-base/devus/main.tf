module "oidc" {
  source       = "../../aws-modules/github-oidc"
  region = var.region
  role_name = var.role_name
  github_repos = var.github_repository
  policy_name   = var.terraform_oidc_policy
  aws_account_id = var.aws_account_id
}

module "vpc" {
  source        = "../../aws-modules/NetworkingV2/modules/vpc"
  region        = var.region
  environment   = var.environment
  vpcs          = var.vpcs
  vpc_flow_logs = var.vpc_flow_logs
}

module "subnet" {
  source                      = "../../aws-modules/NetworkingV2/modules/subnets"
  vpc_id                      = module.vpc.vpc_ids[0]
  vpc_cidr                    = module.vpc.vpc_cidr[0]
  internet_gateway_id         = module.vpc.internet_gateway_ids[0]
  region                      = var.region
  environment                 = var.environment
  nat_gateways                = var.nat_gateways
  private_subnets             = var.private_subnets
  public_subnets              = var.public_subnets
  private_subnet_route_tables = var.private_subnet_route_tables
  public_subnet_route_tables  = var.public_subnet_route_tables

}

module "eks" {
  source                  = "../../aws-modules/eksv2"
  cluster_name            = var.cluster_name
  vpc_id                  = module.vpc.vpc_ids[0]
  private_subnet_ids      = module.subnet.private_subnet_ids
  public_subnet_ids       = module.subnet.public_subnet_ids
  kubernetes_version      = var.kubernetes_version
  worker_nodes_group_list = var.worker_nodes_group_list
  environment             = var.environment
  tags                    = var.tags
  service                 = var.service

}

module "ecr" {
  source           = "../../aws-modules/ecr"
  ecr_repositories = var.ecr_repositories
  kms_key_alias    = var.kms_key_alias
  lifecycle_policy = var.lifecycle_policy
}

#module "pantheon" {
#  source                      = "../../aws-modules/services/pantheon"
#  s3                          = var.s3
#  eks_oidc_provider_url       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#  pantheon_k8s_namespace      = "pantheon"
#  pantheon_s3_service_account = "pantheon"
#  pantheon_role_name          = "zamp-prd-uae-pantheon-irsa-access-role"
#}


module "prometheus" {
  source                     = "../../aws-modules/services/prometheus"
  eks_oidc_provider_url      = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  k8s_namespace              = "monitoring"
  prometheus_service_account = "prometheus"
  prometheus_role_name       = "zamp-prd-uae-prometheus-irsa-access-role"
}

#module "rds" {
#  source             = "../../aws-modules/rds"
#  vpc_id             = module.vpc.vpc_ids[0]
#  vpc_cidr           = module.vpc.vpc_cidr[0]
#  rds                = var.rds
#  private_subnet_ids = module.subnet.private_subnet_ids
#  tags               = var.tags
#  db_sg_name         = "zamp-prd-uae-db-sg"
#  subnet_group_name  = "zamp-prd-uae-subnet-group"
#  kms_key_name = "zamp-prd-uae-db-kms-key"
#}

module "selenium-grid" {
  source = "../../aws-modules/services/selenium-grid"

  s3_bucket_name         = "zamp-prd-uae-selenium-grid-bucket"
  eks_oidc_provider_url  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  k8s_namespace          = "selenium-grid"
  k8s_service_account_name = "selenium-grid-selenium-serviceaccount"
}

module "secrets" {
  source = "../../aws-modules/secrets"
  secrets = var.secrets
  tags = var.tags
}


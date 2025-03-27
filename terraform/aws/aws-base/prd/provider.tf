provider "aws" {
  region     = var.aws_region
}

terraform {
   backend "remote" {
     hostname     = "app.terraform.io"
     organization = "Zampfi"
     workspaces {
       name = "zamp-aws-prd-base"
     }
   }
 }

#  provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

provider "aws" {
  alias  = "databricks"
  region = var.region
  # If the Databricks VPC is in the same account, you don't need to specify different credentials
  # If it's in a different account, you'll need to set up assume role or use different credentials
}
provider "aws" {
  region     = var.aws_region
}

terraform {
   backend "remote" {
     hostname     = "app.terraform.io"
     organization = "Zampfi"
     workspaces {
       name = "zamp-aws-dev-base"
     }
   }
 }



# provider "aws" {
#   alias  = "databricks"
#   region = var.region
#   # If the Databricks VPC is in the same account, you don't need to specify different credentials
#   # If it's in a different account, you'll need to set up assume role or use different credentials
# }
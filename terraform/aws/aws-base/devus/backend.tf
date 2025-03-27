terraform {
  backend "s3" {
    bucket  = "zamp-ai-backend-terraform-demo"
    key     = "dev/state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
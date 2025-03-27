terraform {
  backend "s3" {
    bucket  = "zamp-ai-backend-terraform"
    key     = "prd-uae/state/terraform.tfstate"
    region  = "me-central-1"
    encrypt = true
  }
}

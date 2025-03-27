provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Zampfi"
    workspaces {
      name = "zamp-prod-recon-infra"
    }
  }
}

locals {
  project_prefix = "${var.project}-${var.environment}-${var.region_code[var.region]}"
}

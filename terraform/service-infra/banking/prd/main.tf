provider "google" {
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
}

terraform {
   backend "remote" {
     hostname     = "app.terraform.io"
     organization = "Zampfi"
     workspaces {
       name = "zamp-prd-banking-infra"
     }
   }
 }

locals {
  project_prefix  = "${var.project}-${var.environment}-${var.region_code[var.region]}"
  project_prefix_eu    = "${var.project}-${var.environment_eu}-${var.region_code[var.region_eu]}"
  project_prefix_usa   = "${var.project}-${var.environment_eu}-${var.region_code[var.region_usa]}"

}
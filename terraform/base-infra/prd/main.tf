provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  project = var.project_id
  alias   = "frank"
  region  = "europe-west3"
}

provider "google-beta" {
  project = var.project_id
  alias   = "frank"
  region  = "europe-west3"
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Zampfi"
    workspaces {
      name = "zamp-prd-base-infra"
    }
  }
}

locals {
  project_prefix    = "${var.project}-${var.environment}-${var.region_code[var.region]}"
  project_prefix_eu    = "${var.project}-${var.environment_eu}-${var.region_code[var.region_eu]}"
  project_prefix_usa   = "${var.project}-${var.environment_usa}-${var.region_code[var.region_usa]}"
  basic_roles = [
    "roles/iam.serviceAccountTokenCreator",
    "roles/artifactregistry.writer",
    "roles/container.clusterViewer",
    "roles/container.developer",
    "roles/storage.objectAdmin",
    "roles/secretmanager.viewer",
    "roles/secretmanager.secretAccessor",
    "roles/spanner.databaseUser",
    "roles/spanner.backupWriter"
  ]
}
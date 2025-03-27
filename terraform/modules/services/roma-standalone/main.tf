
#secret manager secrets for neromabula repo

resource "google_secret_manager_secret" "roma_env" {
  secret_id = "${var.project_prefix}-roma-env"
  replication {
    auto {}
  }
}

module "gar_roma" {
  source        = "../../../modules/gar"
  region        = var.region
  repository_id = "${var.project_prefix}-roma-docker-repo"
}
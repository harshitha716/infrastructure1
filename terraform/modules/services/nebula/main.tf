
#secret manager secrets for nebula repo

resource "google_secret_manager_secret" "nebula_env" {
  secret_id = "${var.project_prefix}-nebula-env"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "nebula_lithic_pem" {
  secret_id = "${var.project_prefix}-nebula-lithic-pem"
  replication {
    auto {}
  }
}

resource "google_artifact_registry_repository" "serivce_repository" {
  provider = google-beta
  location = var.region
  repository_id = var.repository_id
  description = "${var.repository_id} docker repository"
  format = "DOCKER"
}


output "service_gar_repo_name" {
  value = google_artifact_registry_repository.serivce_repository.name
}

output "service_gar_repo_arn" {
  value = google_artifact_registry_repository.serivce_repository.id
}

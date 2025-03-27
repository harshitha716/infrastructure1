locals {
    github_action_basic_roles = [
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
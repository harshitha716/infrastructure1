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
  developer_basic_roles = ["roles/iam.serviceAccountTokenCreator", "roles/secretmanager.secretAccessor", "roles/secretmanager.secretVersionAdder", "roles/secretmanager.viewer", "roles/serviceusage.serviceUsageConsumer", "roles/spanner.databaseUser", "roles/spanner.viewer", "roles/storage.objectCreator", "roles/storage.objectViewer", "roles/cloudtasks.enqueuer", "roles/cloudtasks.taskRunner", "roles/cloudtasks.viewer", "roles/container.developer", "roles/container.clusterViewer", "roles/cloudsql.viewer", "roles/logging.viewer", "roles/logging.viewAccessor", "roles/artifactregistry.reader", "roles/monitoring.viewer"]

}
variable "organization" {
  description = "name of the Github Organisation"
}

variable "project_id" {
  description = "GCP project ID"
}

variable "repositories" {
  description = "List of repositories"
}

variable "roles" {
  description = "List of roles to assign to for the github action sa"
}
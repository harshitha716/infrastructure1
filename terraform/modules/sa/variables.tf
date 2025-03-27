variable "proj_prefix" {
  description = "project prefix"
}

variable "roles" {
  description = "list of roles"
  type = list
}

variable "id" {
  description = "identifier for service account"
}

variable "k8s_service_account" {
  description = "flag to identify k8s service account"
}


variable "k8s_service_account_name"{
  description = "k8s sa name"
}
variable "k8s_service_account_namespace"{
  description = "k8s sa namepsace"
}

variable "project_id" {
  description = "project_id "
}
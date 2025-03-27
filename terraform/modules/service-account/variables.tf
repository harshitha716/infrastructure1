variable proj_prefix {
  description = "proj_prefix"
}
variable iam_roles {
  description = "iam_roles"
  default     = []
}
variable service_account_name {
  description = "service_account_name"
}
variable k8s_service_account_namespace {
  description = "k8s_secret_namespace"
  default = "default"
}
variable k8s_service_account_name {
  description = "k8s_secret_name"
}
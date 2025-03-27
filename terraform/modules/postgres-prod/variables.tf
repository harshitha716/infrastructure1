variable proj_prefix {
  description = "proj_prefix"
}
variable subnet {
  description = "subnet"
}
variable iam_roles {
  description = "iam_roles"
  default     = []
}
variable ssh_port {
  description = "ssh_port"
  default     = 121
}
variable ssk_keys {
  description = "ssk_keys"
  default     = {}
}
variable machine_type {
  description = "machine_type"
  default     = "e2-small"
}
variable networks_tags {
  description = "networks_tags"
  default     = []
}
variable block_project_ssh_keys {
  description = "block_project_ssh_keys"
  default     = false
}
variable enable_oslogin {
  description = "enable_oslogin"
  default     = false
}
variable root_disk_size {
  description = "root_disk_size"
  default     = 20
}
variable project_prefix {
  description = "project prefix"
}

# variable sa_name {
#   description = "service account name"
# }

variable roles {
  description = "array service roles to be attached"
  default     = []
}
variable granular_permissions {
  description = "array granular permissions to be attached"
  default     = []
}

variable conditional_custom_roles {
  description = "conditional_custom_role_permissions"
  default     = []
}

variable conditional_roles {
  description = "conditional_role_permissions"
  default     = []
}

variable member {
  description = "member mail ID"
}


variable role_name {
  description = "role_name"
}


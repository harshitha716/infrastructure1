locals {
  members_yaml                      = file("${path.module}/iam/members.yaml")
  members_map                       = yamldecode(local.members_yaml)
  developer_readonly_members        = local.members_map.readonly == null ? [] : local.members_map.readonly
  developer_admin_members           = local.members_map.admin == null ? [] : local.members_map.admin
  temporary_developer_admin_members = local.members_map.admin-temp == null ? [] : local.members_map.admin-temp
  temporary_access_timestamp        = timeadd(timestamp(), "4h")
}
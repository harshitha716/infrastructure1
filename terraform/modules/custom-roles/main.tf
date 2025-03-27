data "google_project" "project" {
}



## Predifined Role Binding 
resource "google_project_iam_member" "role_binding" {
  for_each = length(var.roles) > 0 ? local.role_map : {}
  project  = data.google_project.project.id
  role     = each.value.role
  member   = each.value.member
}

## Custom Role
resource "google_project_iam_custom_role" "custom_role" { 
  count       =  length(var.granular_permissions) > 0 ? 1 : 0
  role_id     = "${replace(var.role_name, "-", "_")}_custom_role"
  title       = "${var.role_name}-custom-role"
  description = "${var.role_name} custom role"
  permissions =  var.granular_permissions
}

## Custom Role Binding
resource "google_project_iam_member" "custom_role_binding" {
  for_each = length(var.granular_permissions) > 0 ? toset(var.member) : []
  project  = data.google_project.project.id
  role     = google_project_iam_custom_role.custom_role[0].id
  member   = each.value
 }

## Conditional Custom Role
resource "google_project_iam_custom_role" "conditional_custom_role" {
  for_each =  { for index, roles in var.conditional_custom_roles : roles.id => roles } 
  role_id     = "${replace(var.role_name, "-", "_")}_conditional_custom_role_${each.key}"
  title       = "${var.role_name}-conditional-custom-role-${each.key}"
  description = "${var.role_name} conditional custom role ${each.key}"
  permissions =  each.value.roles
}

## Conditional Custom Role Binding
resource "google_project_iam_member" "conditional_custom_role_binding" {
  for_each = length(var.conditional_custom_roles) > 0 ? local.conditional_custom_roles_map : {}
  project  = data.google_project.project.id
  role     = google_project_iam_custom_role.conditional_custom_role["${each.value.id}"].id
  member = each.value.member
  condition {
    title       = each.value.title
    description = each.value.title
    expression  = each.value.expression
  }
 }

## Conditional Role Binding
 resource "google_project_iam_member" "conditional_role_binding" {
  for_each = length(var.conditional_roles) > 0 ? local.conditional_roles_map : {}
  project  = data.google_project.project.id
  role     = each.value.role
  member = each.value.member
  condition {
    title       = each.value.title
    description = each.value.title
    expression  = each.value.expression
  }
}

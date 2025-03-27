locals {
  role_list = flatten([for i,member in var.member : [for j,role in var.roles : {
    member = member
    role = role
  }]])

  role_map = {for i,x in local.role_list : "${x.member}-${tostring(i)}" => x}

  conditional_roles_list = flatten([for i,member in var.member : [for j,role in var.conditional_roles : {
    id = role.id
    role = role.role
    title = role.title
    expression = role.expression
    member = member
  }]])

  conditional_roles_map = {for i,x in local.conditional_roles_list : "${x.id}-${tostring(i)}" => x}

  conditional_custom_roles_list = flatten([for i,member in var.member : [for j,role in var.conditional_custom_roles : {
    member = member
    id = role.id
    roles = role.roles
    title = role.title
    expression = role.expression
  }]])

  conditional_custom_roles_map = {for i,x in local.conditional_custom_roles_list : "${x.id}-${tostring(i)}" => x}

}
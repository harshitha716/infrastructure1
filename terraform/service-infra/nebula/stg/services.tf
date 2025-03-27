
#### Nebula services
module "nebula" {
  source                = "../../../modules/services/nebula"
  project_prefix        = local.project_prefix
}


module "nebula-web" {
  static_hosting_domain = "nebula.stg.zamplabs.com"
  source                = "../../../modules/services/ui"
  proj_prefix           = local.project_prefix
  name_tag              = "nebula-ui"
}
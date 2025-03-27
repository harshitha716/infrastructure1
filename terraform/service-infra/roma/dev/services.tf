#### Roma services
module "roma-web" {
  static_hosting_domain = "roma.dev.zamplabs.com"
  source                = "../../../modules/services/ui"
  proj_prefix           = local.project_prefix
  name_tag              = "roma-ui"
}

module "roma-backend" {
  source         = "../../../modules/services/roma"
  project_prefix = local.project_prefix
  #region         = var.region
}

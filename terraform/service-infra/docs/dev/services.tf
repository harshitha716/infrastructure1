module "docs" {
  static_hosting_domain = "docs.dev.zamplabs.com"
  source                = "../../../modules/services/ui"
  proj_prefix           = local.project_prefix
  name_tag              = "docs-ui"
}
# OLD CODE
# module "docs" {
#   static_hosting_domain = "docs.zamplabs.com"
#   source                = "../../../modules/services/ui"
#   proj_prefix           = local.project_prefix
#   name_tag              = "docs-ui"
# }

module "docs-2" {
  static_hosting_domain = ["docs.zamplabs.com", "docs.roma.global"]
  source                = "../../../modules/services/ui-v2"
  proj_prefix           = local.project_prefix
  name_tag              = "docs-ui"
}
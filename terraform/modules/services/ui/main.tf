# module "cdn" {
#   source                = "../../../modules/cdn-static-hosting"
#   proj_prefix           = var.proj_prefix
#   name_tag              = var.name_tag
#   static_hosting_domain = var.static_hosting_domain
#   only_vpn_access = var.only_vpn_access
#   vpn_connector_ip = var.vpn_connector_ip
# }

resource "google_secret_manager_secret" "secret_manager_secret" {
  secret_id = "${var.proj_prefix}-${var.name_tag}-env"
  replication {
    auto {}
  }
}
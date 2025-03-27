module "compute_alerts" {
  source                = "../../modules/alerts/compute"
  project_id            = var.project_id
  notification_channels = ["13493621567209400797","8404933273215698076"]
  user_labels           = local.user_labels
}


module "application_alerts" {
  source                = "../../modules/alerts/application"
  project_id            = var.project_id
  notification_channels = ["13493621567209400797","8404933273215698076"]
  user_labels           = local.user_labels
}
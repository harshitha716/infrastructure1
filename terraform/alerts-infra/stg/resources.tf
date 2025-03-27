module "compute_alerts" {
  source                = "../../modules/alerts/compute"
  project_id            = var.project_id
  notification_channels = ["10429755156554174797"]
  user_labels           = local.user_labels
}


module "application_alerts" {
  source                = "../../modules/alerts/application"
  project_id            = var.project_id
  notification_channels = ["10429755156554174797"]
  user_labels           = local.user_labels
}
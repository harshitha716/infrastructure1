module "compute_alerts" {
  source                = "../../modules/alerts/compute"
  project_id            = var.project_id
  notification_channels = ["17452740195716298134","11386049633809975116"]
  user_labels           = local.user_labels
}


module "application_alerts" {
  source                = "../../modules/alerts/application"
  project_id            = var.project_id
  notification_channels = ["17452740195716298134","11386049633809975116"]
  user_labels           = local.user_labels
}

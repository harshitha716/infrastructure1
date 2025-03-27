
module "recon-backend" {
  source         = "../../../modules/services/recon"
  project_prefix = local.project_prefix
  #region         = var.region
}
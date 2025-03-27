resource "google_composer_environment" "composer_environment" {
  name   = var.name
  region = var.region

  config {

    resilience_mode = var.resilience_mode

    node_config {
      service_account = var.service_account
      network                    = var.network
      subnetwork                 = var.subnetwork
    }
    # Image version and Python version
    software_config {
      image_version  = var.image_version
      pypi_packages = {
        "apache-airflow-providers-cncf-kubernetes" = ">=5.1.0"
        "kubernetes" = ">=21.7.0"
        "apache-airflow-providers-google" = ">=10.0.0"
      }
  }
}
}
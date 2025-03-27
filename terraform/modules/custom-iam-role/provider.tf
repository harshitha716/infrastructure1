terraform {
  required_version = ">= 0.13"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = ">= 5.4.0, < 6.0.0"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-iam:custom_role_iam/v7.4.1"
  }

}

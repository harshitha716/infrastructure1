terraform {
  required_providers {
    google = {
      source  = "registry.terraform.io/hashicorp/google"
      version = "4.59.0"
    }
    google-beta = {
      source  = "registry.terraform.io/hashicorp/google-beta" 
      version = "4.59.0"
    }
  }
}


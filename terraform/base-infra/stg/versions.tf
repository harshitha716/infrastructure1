terraform {
  required_providers {
    google = {
      source  = "registry.terraform.io/hashicorp/google"
      version = ">= 5.4.0, < 6.0.0"
    }
    google-beta = {
      source  = "registry.terraform.io/hashicorp/google-beta" 
      version = "3.89.0"
    }
  }
}


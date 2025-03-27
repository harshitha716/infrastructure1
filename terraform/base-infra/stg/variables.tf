variable "region_code" {
  type = map
  default = {
    asia-south1      = "mb" # Mumbai
    asia-south2      = "dl" # Delhi
    asia-southeast1  = "sg"
    us-west1        = "us" #oregon

  }
} 

variable project_id {
  description = "google project id"
}
variable project {
  description = "project name"
}
variable environment {
  description = "environment name"
}
variable region {
  description = "region name"
}
variable default_zone {
  description = "default_zone"
}
# variable vpc_public_subnet_cidr {
#   description = "vpc_public_subnet_cidr"
# }
# variable vpc_private_subnet_cidr {
#   description = "vpc_private_subnet_cidr"
# }
# variable vpc_private_proxy_subnet_cidr {
#   description = "vpc_private_proxy_subnet_cidr"
# }
variable firewall_office_ip_list {
  description = "firewall_office_ip_list"
}
variable gke_master_ipv4_cidr_block {
  description = "gke_master_ipv4_cidr_block"
}

variable cloudspanner_processing_units {
  description = "cloudspanner_node_count"
}

variable "open_vpn_token" {
  default= "test"
}

#CloudSQL
variable "tier" {
  type = string
  default = "db-custom-1-4096"
}

variable "disk_size_gb" {
  type = number
  default = "20"
}

variable "postgress_pass" {
  default = "password"
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "database_ids" {
  type = set(string)
}

variable "spanner_instance_id" {
  type = string
}

variable "schedule" {
  type    = string
}

variable "WEBHOOK_URL" {
  type    = string
}

variable "postgress_pass_recon" {
  default = "password"
}

variable "postgress_pass_hcp" {
  default = "password"
}
variable "tier_hcp" {
  type = string
  default = "db-custom-1-4096"
}
variable "region_usa" {
  description = "region name"
}

variable "default_zone_usa" {
  description = "default zone"
}

variable "environment_usa" {
  description = "region name"
}

variable "nat_ip_count_usa" {
  description = "number of nat instances"
  default = 1  
}

# #Composer Vairables
# variable "image_version" {
#   type        = string
#   default     = "composer-3-airflow-2.10.2-build.0"
# }
# variable "enable_private_environment" {
#   type        = bool
#   default     = true
# }
# variable "service_account" {
#   type        = string
#   default     = "321085961264-compute@developer.gserviceaccount.com"
# }
# variable "scheduler_count" {
#   type        = number
#   default     = 2
# }
# variable "network" {
#   type        = string
#   default     = "projects/staging-351109/global/networks/zamp-stg-sg-vpc"
# }
# variable "subnetwork" {
#   type        = string
#   default     = "projects/staging-351109/regions/asia-southeast1/subnetworks/zamp-stg-sg-vpc"
# }
# variable "scheduler_memory_gb" {
#   type        = number
#   default     = 4
# }
# variable "triggerer_cpu" {
#   type        = number
#   default     = 0.5
# }
# variable "triggerer_storage_gb" {
#   type        = number
#   default     = 1
# }
# variable "resilience_mode" {
#   type        = string
#   default     = "STANDARD_RESILIENCE"
# }
# variable "enable_web_server_plugins" {
#   type        = bool
#   default     = true
# }
# variable "dag_processor_memory_gb" {
#   type        = number
#   default     = 7.5
# }
# variable "web_server_memory_gb" {
#   type        = number
#   default     = 7.5
# }
# variable "web_server_storage_gb" {
#   type        = number
#   default     = 5
# }
# variable "worker_storage_gb" {
#   type        = number
#   default     = 20
# }
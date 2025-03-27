# Generic Variables
project_id           = "development-351109"
project              = "zamp"
environment          = "dev"
region               = "asia-southeast1"
default_zone         = "asia-southeast1-a"

# VPC
# vpc_public_subnet_cidr            = "10.40.2.0/24"
# vpc_private_subnet_cidr           = "10.40.4.0/24" 
# vpc_private_proxy_subnet_cidr     = "10.40.6.0/23"

# Firewall
firewall_office_ip_list    = ["103.214.233.88/32","61.2.141.1/32","14.142.179.226/32"]

# GKE
gke_master_ipv4_cidr_block = "10.40.8.0/28"


cloudspanner_processing_units = 400

output "environment" {
  value = var.environment
}


output "region" {
  value = var.region
}
output "vpc_ids" {
  value = module.vpc.vpc_ids
}

output "internet_gateway_ids" {
  value = module.vpc.internet_gateway_ids
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "nat_gateway_ids" {
  value = module.subnet.nat_gateway_ids
}

output "public_subnet_ids" {
  value = module.subnet.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnet.private_subnet_ids
}

output "nat_gateway_public_ips" {
  value = module.subnet.nat_gateway_public_ips
}


output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

# # output "node_group_arns" {
# #   value = module.eks.node_group_arns.arn
# # }

# output "bastion_public_ip" {
#   description = "The public IP address of the bastion host"
#   value       = module.bastion.bastion_public_ip
# }
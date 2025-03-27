resource "aws_eip" "elastic_ip" {
  count = length(var.nat_gateways)
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.nat_gateways[count.index], "name") }),
    lookup(var.nat_gateways[count.index], "tags")
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.nat_gateways)
  allocation_id = aws_eip.elastic_ip.*.id[count.index]
  subnet_id     = aws_subnet.public_subnets.*.id[count.index]
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.nat_gateways[count.index], "name") }),
    lookup(var.nat_gateways[count.index], "tags")
  )
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = var.vpc_id
  cidr_block        = lookup(var.private_subnets[count.index], "cidr")
  availability_zone = lookup(var.private_subnets[count.index], "availability_zone")
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.private_subnets[count.index], "name") }),
    lookup(var.private_subnets[count.index], "tags")
  )
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets)
  vpc_id            = var.vpc_id
  cidr_block        = lookup(var.public_subnets[count.index], "cidr")
  availability_zone = lookup(var.public_subnets[count.index], "availability_zone")
  map_public_ip_on_launch = true
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.public_subnets[count.index], "name") }),
    lookup(var.public_subnets[count.index], "tags")
  )
}

resource "aws_vpc_endpoint" "gateway_endpoint_for_s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
    Name        = "s3-gateway-endpoint"
    Environment = var.environment
    Terraformed = "True"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_endpoint_association_with_private_route_table" {
  count           = length(var.private_subnet_route_tables)
  route_table_id  = aws_route_table.private_subnet_route_table.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.gateway_endpoint_for_s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_endpoint_association_with_public_route_table" {
  count           = length(var.public_subnet_route_tables)
  route_table_id  = aws_route_table.public_subnet_route_table.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.gateway_endpoint_for_s3.id
}

resource "aws_security_group" "security_group_for_vpc_interface_endpoints" {
  name   = "vpc-interface-endpoints"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow traffic on port 443 from the self network"
  }
  tags = {
    Name        = "vpc-interface-endpoints"
    Environment = var.environment
    Terraformed = "True"
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  count  = length(var.private_subnet_route_tables)
  vpc_id = var.vpc_id
  route {
    cidr_block                 = "0.0.0.0/0"
    nat_gateway_id             = element(aws_nat_gateway.nat_gateway[*].id, count.index)
    # egress_only_gateway_id     = ""
    # gateway_id                 = ""
    # instance_id                = ""
    # # ipv6_cidr_block            = ""
    # network_interface_id       = ""
    # transit_gateway_id         = ""
    # vpc_peering_connection_id  = ""
    # carrier_gateway_id         = ""
    # destination_prefix_list_id = ""
    # local_gateway_id           = ""
    # vpc_endpoint_id            = ""
  }
    tags   = merge(tomap({Environment =  var.environment,
              Name = lookup(var.private_subnet_route_tables[count.index],"name") }),
              lookup(var.private_subnet_route_tables[count.index],"tags")
              )   
 route {
    cidr_block                = var.databricks_vpc_peering_connection.vpc_cidr
    vpc_peering_connection_id = data.aws_vpc_peering_connection.databricks_vpc_peering.id
  }
  }


  resource "aws_route_table" "public_subnet_route_table" {
  count  = length(var.public_subnet_route_tables)
  vpc_id = var.vpc_id
  route {
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = var.internet_gateway_id
    # nat_gateway_id             = ""
    # egress_only_gateway_id     = ""
    # instance_id                = ""
    # # ipv6_cidr_block            = ""
    # network_interface_id       = ""
    # transit_gateway_id         = ""
    # vpc_peering_connection_id  = ""
    # carrier_gateway_id         = ""
    # destination_prefix_list_id = ""
    # local_gateway_id           = ""
    # vpc_endpoint_id            = ""
  }
  tags   = merge(tomap({Environment =  var.environment,
              Name = lookup(var.public_subnet_route_tables[count.index],"name") }),
              lookup(var.public_subnet_route_tables[count.index],"tags")
          ) 
   route {
    cidr_block                = var.databricks_vpc_peering_connection.vpc_cidr
    vpc_peering_connection_id = data.aws_vpc_peering_connection.databricks_vpc_peering.id
  }     
  }

resource "aws_route_table_association" "private_subnet_route_table_association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets.*.id[count.index%length(var.private_subnets)]
  route_table_id = aws_route_table.private_subnet_route_table.*.id[count.index % length(var.private_subnet_route_tables)]
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets.*.id[count.index%length(var.public_subnets)]
  route_table_id = aws_route_table.public_subnet_route_table.*.id[0]
}


#vpc-peering with Databricks quickstart VPC

data "aws_vpc_peering_connection" "databricks_vpc_peering" {
  id = "pcx-0e2961d20e5e69860"  
}


resource "aws_route" "private_subnet_to_databricks" {
  count                     = length(aws_route_table.private_subnet_route_table)
  route_table_id            = aws_route_table.private_subnet_route_table[count.index].id
  destination_cidr_block    = var.databricks_vpc_peering_connection.vpc_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.databricks_vpc_peering.id
}

resource "aws_route" "public_subnet_to_databricks" {
  count                     = length(aws_route_table.public_subnet_route_table)
  route_table_id            = aws_route_table.public_subnet_route_table[count.index].id
  destination_cidr_block    = var.databricks_vpc_peering_connection.vpc_cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.databricks_vpc_peering.id
}
# DB-VPC Peering Connection
# resource "aws_vpc_peering_connection" "databricks_vpc_peering_connection" {
#   vpc_id        = var.vpc_id
#   peer_vpc_id   = var.databricks_vpc_peering_connection.vpc_id
#   peer_owner_id = var.databricks_vpc_peering_connection.account_id
#   peer_region   = var.databricks_vpc_peering_connection.vpc_region
#   tags = {
#     Environment = var.environment,
#     Name        = var.databricks_vpc_peering_connection.name,
#     Terraformed = "True"
#   }
#     lifecycle {
#     create_before_destroy = true
#   }
#   timeouts {
#     create = "15m"
#     delete = "15m"
#   }
# }

# resource "aws_vpc_peering_connection_options" "peering_connection_options_in_local_vpc" {
#   vpc_peering_connection_id = aws_vpc_peering_connection.databricks_vpc_peering_connection.id
#   requester {
#     allow_remote_vpc_dns_resolution = true
#   }
#   depends_on = [aws_vpc_peering_connection_accepter.databricks_vpc_peering_connection_accepter]
# }

# resource "aws_vpc_peering_connection_options" "peering_connection_options_in_remote_vpc" {
#   provider                  = aws.databricks
#   vpc_peering_connection_id = aws_vpc_peering_connection.databricks_vpc_peering_connection.id
#   accepter {
#     allow_remote_vpc_dns_resolution = true
#   }
#   depends_on = [aws_vpc_peering_connection_accepter.databricks_vpc_peering_connection_accepter]
# }

# resource "aws_vpc_peering_connection_accepter" "databricks_vpc_peering_connection_accepter" {
#   provider                  = aws.databricks
#   vpc_peering_connection_id = aws_vpc_peering_connection.databricks_vpc_peering_connection.id
#   auto_accept               = true
#   tags = {
#     Environment = var.environment,
#     Name        = var.databricks_vpc_peering_connection.name,
#     Terraformed = "True"
#   }
# }
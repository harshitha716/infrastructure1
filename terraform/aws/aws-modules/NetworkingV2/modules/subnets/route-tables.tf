

  resource "aws_route_table" "public_subnet_route_table" {
  count  = length(var.public_subnet_route_tables)
  vpc_id = var.vpc_id
  route {
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = var.internet_gateway_id

  }
  route {
    cidr_block           = var.cidr_block_ip1   # This has been added for VPN Connection
    network_interface_id = var.network_interface_id 
  }
  route {
      cidr_block           = var.cidr_block_ip2  # This has been added for VPN Connection
      network_interface_id = var.network_interface_id
  }

  tags   = merge(tomap({Environment =  var.environment,
              Name = lookup(var.public_subnet_route_tables[count.index],"name") }),
              lookup(var.public_subnet_route_tables[count.index],"tags")
          ) 
   
  }


resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets.*.id[count.index%length(var.public_subnets)]
  route_table_id = aws_route_table.public_subnet_route_table.*.id[0]
}



resource "aws_route_table" "private_subnet_route_table" {
  count  = length(var.private_subnet_route_tables)
  vpc_id = var.vpc_id
  route {
    cidr_block                 = "0.0.0.0/0"
    nat_gateway_id             = element(aws_nat_gateway.nat_gateway[*].id, count.index)

  }
    tags   = merge(tomap({Environment =  var.environment,
              Name = lookup(var.private_subnet_route_tables[count.index],"name") }),
              lookup(var.private_subnet_route_tables[count.index],"tags")
              )   
  }


resource "aws_route_table_association" "private_subnet_route_table_association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets.*.id[count.index%length(var.private_subnets)]
  route_table_id = aws_route_table.private_subnet_route_table.*.id[count.index % length(var.private_subnet_route_tables)]
}


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
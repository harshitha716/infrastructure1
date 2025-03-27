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








resource "aws_vpc" "vpc" {
  count                = length(var.vpcs)
  cidr_block           = lookup(var.vpcs[count.index], "cidr")
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.vpcs[count.index], "name")  }),
    lookup(var.vpcs[count.index], "tags")
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  count  = length(var.vpcs)
  vpc_id = aws_vpc.vpc.*.id[count.index]
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.vpcs[count.index], "name")  }),
    lookup(var.vpcs[count.index], "tags")
  )
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  count               = length(var.vpcs)
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = merge(tomap({ Environment = var.environment,
    Name = lookup(var.vpcs[count.index], "name")  }),
    lookup(var.vpcs[count.index], "tags")
  )
}
resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  count           = length(var.vpcs)
  vpc_id          = aws_vpc.vpc.*.id[count.index]
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.*.id[count.index]
}

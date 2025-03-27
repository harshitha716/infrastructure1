output "vpc_ids" {
  value = aws_vpc.vpc.*.id
}

output "internet_gateway_ids" {
  value = aws_internet_gateway.internet_gateway.*.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.*.cidr_block
  
}
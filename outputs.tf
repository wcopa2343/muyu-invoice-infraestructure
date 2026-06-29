# Reserved for future Terraform outputs such as VPC and subnet identifiers.
# VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Public subnets
output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

# Private subnets
output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

# Internet Gateway
output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

# NAT Gateway
output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

# NAT Elastic IP (public IP)
output "nat_eip_public_ip" {
  value = aws_eip.nat_eip.public_ip
}
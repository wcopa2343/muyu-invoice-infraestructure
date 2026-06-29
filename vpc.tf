# VPC resources will be defined here when network infrastructure is implemented.
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name_prefix}-${var.env}-vpc"
  }
}


# Public subnet resources will be added here for internet-facing components.
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-${var.env}-public-subnet-1"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-${var.env}-public-subnet-2"
  }
}

# Private subnet resources will be added here for internal components.
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private1_cidr
  availability_zone = var.availability_zone1

  tags = {
    Name = "${var.name_prefix}-${var.env}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private2_cidr
  availability_zone = var.availability_zone2

  tags = {
    Name = "${var.name_prefix}-${var.env}-private-subnet-2"
  }
}

# Internet Gateway resources will be added here for public internet access.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-${var.env}-internet-gateway"
  }
}

# Elastic IP resources will be added here for NAT Gateway access to the internet.
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.name_prefix}-${var.env}-nat-eip"
  }
}

# NAT Gateway lets private subnets reach the internet without being public.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${var.name_prefix}-${var.env}-nat-gateway"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

# Route Tables will be added here for public and private subnet routing.
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-${var.env}-rt-public"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


# Public subnets use the public route table, which sends internet traffic to the Internet Gateway.
resource "aws_route_table_association" "public1_association" {
  route_table_id = aws_route_table.rt_public.id
  subnet_id      = aws_subnet.public_subnet_1.id
}


resource "aws_route_table_association" "public2_association" {
  route_table_id = aws_route_table.rt_public.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

# Private route table sends internet traffic through the NAT Gateway.
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-${var.env}-rt-private"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}


# Private subnets use the private route table, which sends internet traffic to the NAT Gateway.
resource "aws_route_table_association" "private1_association" {
  route_table_id = aws_route_table.rt_private.id
  subnet_id      = aws_subnet.private_subnet_1.id
}


resource "aws_route_table_association" "private2_association" {
  route_table_id = aws_route_table.rt_private.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

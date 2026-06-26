# VPC resources will be defined here when network infrastructure is implemented.
resource "aws_vpc" "muyu" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Muyu-vpc"
  }
}


# Public subnet resources will be added here for internet-facing components.
resource "aws_subnet" "class2-public-subnet-1" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = "10.10.1.0/24"
  # map_public_ip_on_launch = true # in orde to allow public IPs to be assigned to instances in this subnet

  tags = {
    Name = "class2-public-subnet-1"
  }
}


resource "aws_subnet" "class2-public-subnet-2" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "class2-public-subnet-2"
  }
}

# Private subnet resources will be added here for internal components.
resource "aws_subnet" "class2-private-subnet-1" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = "10.10.3.0/24"

  tags = {
    Name = "class2-private-subnet-1"
  }
}

resource "aws_subnet" "class2-private-subnet-2" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = "10.10.4.0/24"

  tags = {
    Name = "class2-private-subnet-2"
  }
}



# Internet Gateway resources will be added here for public internet access.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.muyu.id

  tags = {
    Name = "muyu-igw"
  }
}

# Elastic IP resources will be added here for NAT Gateway access to the internet.
resource "aws_eip" "class2-bootcamp-nat-eip" {
  # instance = aws_instance.web.id
  domain = "vpc"
  tags = {
    Name = "class2-bootcamp-nat-eip"
  }
}

resource "aws_nat_gateway" "class2-bootcamp-nat-gateway" {
  allocation_id = aws_eip.class2-bootcamp-nat-eip.id

  subnet_id = aws_subnet.class2-public-subnet-2.id

  tags = {
    Name = "class2-bootcamp-nat-gateway"
  }

  depends_on = [
    aws_internet_gateway.gw
  ]
}

# Route Tables will be added here for public and private subnet routing.
resource "aws_route_table" "class2-bootcamp-rt-public" {
  vpc_id = aws_vpc.muyu.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  #It is added automatically
  # route {
  #   cidr_block = "10.1.0.0/16"
  #   gateway_id = "local"
  # }

  tags = {
    Name = "class2-bootcamp-rt-public"
  }
}


resource "aws_route_table" "class2-bootcamp-rt-private" {
  vpc_id = aws_vpc.muyu.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.class2-bootcamp-nat-gateway.id
  }
  # it is added automatically
  # route {
  #   cidr_block = "10.1.0.0/16"
  #   gateway_id = "local"
  # }

  tags = {
    Name = "class2-bootcamp-rt-private"
  }

}

# Route Table Associations will be added here to attach subnets to routes.
# Public
resource "aws_route_table_association" "class2-public-subnet-1-association" {
  subnet_id      = aws_subnet.class2-public-subnet-1.id
  route_table_id = aws_route_table.class2-bootcamp-rt-public.id
}


resource "aws_route_table_association" "class2-public-subnet-2-association" {
  subnet_id      = aws_subnet.class2-public-subnet-2.id
  route_table_id = aws_route_table.class2-bootcamp-rt-public.id
}

# Private
resource "aws_route_table_association" "class2-private-subnet-1-association" {
  subnet_id      = aws_subnet.class2-private-subnet-1.id
  route_table_id = aws_route_table.class2-bootcamp-rt-private.id
}


resource "aws_route_table_association" "class2-private-subnet-2-association" {
  subnet_id      = aws_subnet.class2-private-subnet-2.id
  route_table_id = aws_route_table.class2-bootcamp-rt-private.id
}

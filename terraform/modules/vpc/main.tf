# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Public subnets and NAT Gateways in each AZ
resource "aws_subnet" "public" {
  count                = length(var.public_subnet_cidrs)
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = var.public_subnet_cidrs[count.index]
  availability_zone    = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Elastic IPs in each AZ
resource "aws_eip" "nat" {
  count = length(var.azs)
  vpc      = true

  tags = {
    Name = "${var.project_name}-nat-eip-${count.index}"
  }
}

# Create NAT Gateways in each AZ
resource "aws_nat_gateway" "nat" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-gateway-${count.index}"
  }
}

# Private Application Subnets
resource "aws_subnet" "private_app" {
  count                = length(var.private_app_subnet_cidrs)
  vpc_id               = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-app-subnet-${count.index}"
  }
}

# Create Application Route Table in each AZ
resource "aws_route_table" "private_app" {
  count  = length(var.azs)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.project_name}-app-rt-${count.index}"
  }
}

# Associate Route Table with Application Private Subnets
resource "aws_route_table_association" "private_app" {
  count          = length(var.private_app_subnet_cidrs)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private Data Subnets
resource "aws_subnet" "private_data" {
  count                   = length(var.private_data_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_data_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-data-subnet-${count.index}"
  }
}

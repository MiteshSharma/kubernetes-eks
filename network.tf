#providers
provider "aws" {
  region     = var.region
}

#resources
resource "aws_vpc" "networking" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Environment" = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "networking" {
  vpc_id = aws_vpc.networking.id
  tags = {
    "Environment" = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "networking" {
  count                   = length(var.subnets)
  vpc_id                  = aws_vpc.networking.id
  cidr_block              = element(values(var.subnets), count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(keys(var.subnets), count.index)
  tags = {
    "Environment" = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "networking" {
  vpc_id = aws_vpc.networking.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.networking.id
  }

  tags = {
    "Environment" = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_route_table_association" "networking" {
  count          = length(var.subnets)
  subnet_id      = element(aws_subnet.networking.*.id, count.index)
  route_table_id = aws_route_table.networking.id
}

resource "aws_key_pair" "ec2key" {
  key_name   = "publicKey"
  public_key = file(var.public_key_path)
}



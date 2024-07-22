# AWS plugin  
provider "aws" {
  region = "us-east-1"
}

#EKS-CLuster
#Create VPC with Four-subnets(2-public,2-private)
#Create VPC
resource "aws_vpc" "node_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true #instance use route53 as DNS
  enable_dns_hostnames = true #give ec2 DNS

  tags = {
    Name = "node-vpc"
  }
}

#Create First public_subnet_01
resource "aws_subnet" "public_subnet_01" {
  vpc_id                  = aws_vpc.node_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                     = "public_subnet_01"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/eks-cluster-test" = "owned"
  }
}

#Create Second public_subnet_02
resource "aws_subnet" "public_subnet_02" {
  vpc_id                  = aws_vpc.node_vpc.id
  cidr_block              = "10.0.64.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name                                     = "public_subnet_02"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/eks-cluster-test" = "owned"
  }
}

#Create First private_subnet_01
resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.node_vpc.id
  cidr_block        = "10.0.128.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name                                     = "private_subnet_01"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/eks-cluster-test" = "owned"
  }
}

#Create Second private_subnet_02
resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.node_vpc.id
  cidr_block        = "10.0.192.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name                                     = "private_subnet_02"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/eks-cluster-test" = "owned"
  }
}


#Create IGW 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.node_vpc.id
  tags = {
    Name = "igw"
  }
}

#Allocate eip for First NAT in public_subnet_01
resource "aws_eip" "nat_eip_01" {
  vpc = true
  #indicate that the Elastic IP is intended for use within a VPC.

}

# Create a First NAT Gateway in public_subnet_01
resource "aws_nat_gateway" "nat_01" {
  allocation_id = aws_eip.nat_eip_01.id
  subnet_id     = aws_subnet.public_subnet_01.id

  tags = {
    Name = "NATGateway_public_subnet_01"
  }
}

#Allocate eip for Second NAT in public_subnet_02
resource "aws_eip" "nat_eip_02" {
  vpc = true
  #indicate that the Elastic IP is intended for use within a VPC.

}

# Create a Second NAT Gateway in public_subnet_02
resource "aws_nat_gateway" "nat_02" {
  allocation_id = aws_eip.nat_eip_02.id
  subnet_id     = aws_subnet.public_subnet_02.id

  tags = {
    Name = "NATGateway_public_subnet_02"
  }
}

#Create route table for public subnet to route to igw
resource "aws_route_table" "route_table_public_igw" {
  vpc_id = aws_vpc.node_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Associate first public_subnet_01 with public route table(route_table_public_igw)
resource "aws_route_table_association" "association_public_subnet_01" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.route_table_public_igw.id
}

#Associate Second public_subnet_02 with public route table(route_table_public_igw)
resource "aws_route_table_association" "association_public_subnet_02" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.route_table_public_igw.id
}

#Create route table for private_subnet_01 to route to NATGateway_public_subnet_01
resource "aws_route_table" "route_table_private_nat_01" {
  vpc_id = aws_vpc.node_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_01.id
  }
}

#Create route table for private_subnet_02 to route to NATGateway_public_subnet_02
resource "aws_route_table" "route_table_private_nat_02" {
  vpc_id = aws_vpc.node_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_02.id
  }
}

#Associate first private_subnet_01 with private route table(route_table_private_nat_01)
resource "aws_route_table_association" "association_private_subnet_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.route_table_private_nat_01.id
}

#Associate Second private_subnet_02 with private route table(route_table_private_nat_02)
resource "aws_route_table_association" "association_private_subnet_02" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.route_table_private_nat_02.id
}










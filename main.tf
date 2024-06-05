resource "aws_vpc" "homelab-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = " Homelab "
  }

}

resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.homelab-vpc.id
  cidr_block              = "10.123.0.0/16"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"


  tags = {
    Name = "public-subnet1"
  }
}



resource "aws_internet_gateway" "homelab-igw" {
  vpc_id = aws_vpc.homelab-vpc.id

  tags = {
    Name = "Homelabs-igw"
  }

}

resource "aws_route_table" "homelab-rt" {
  vpc_id = aws_vpc.homelab-vpc.id

  tags = {
    Name = "Homelabs-rt"
  }

}



resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.homelab-rt.id
  destination_cidr_block = "0.0.0.0/16"
  gateway_id             = aws_internet_gateway.homelab-igw.id
}

resource "aws_route_table_association" "homelab-rta" {
  route_table_id = aws_route_table.homelab-rt.id
  gateway_id     = aws_internet_gateway.homelab-igw.id
}

resource "aws_security_group" "public-sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.homelab-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["73.172.56.221/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
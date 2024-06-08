resource "aws_vpc" "homelab-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Homelab"
  }
}

resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.homelab-vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_internet_gateway" "homelab-igw" {
  vpc_id = aws_vpc.homelab-vpc.id

  tags = {
    Name = "Homelab-igw"
  }
}

resource "aws_route_table" "homelab-rt" {
  vpc_id = aws_vpc.homelab-vpc.id

  tags = {
    Name = "Homelab-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.homelab-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.homelab-igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.homelab-rt.id
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

resource "aws_key_pair" "homelab-auth" {
  key_name   = "kb-auth"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "dev-node" {
  instance_type          = "t3.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.homelab-auth.key_name
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  subnet_id              = aws_subnet.public-subnet1.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
}
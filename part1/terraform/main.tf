terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.28.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region = var.region
}

resource "aws_vpc" "part1" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "part1_public1" {
  vpc_id = aws_vpc.part1.id
  cidr_block = "10.0.0.0/28"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "part1_public2" {
  vpc_id = aws_vpc.part1.id
  cidr_block = "10.0.1.0/28"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "part1_private1" {
  vpc_id = aws_vpc.part1.id
  cidr_block = "10.0.2.0/28"
}

resource "aws_subnet" "part1_private2" {
  vpc_id = aws_vpc.part1.id
  cidr_block = "10.0.3.0/28"
}

resource "aws_eip" "part1" {
  vpc = true
}

resource "aws_nat_gateway" "part1" {
  subnet_id = aws_subnet.part1_public1.id
  allocation_id = aws_eip.part1.id
}

resource "aws_route_table" "part1_nat" {
  vpc_id = aws_vpc.part1.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.part1.id
  }
}

resource "aws_route_table_association" "part1_private1" {
  route_table_id = aws_route_table.part1_nat.id
  subnet_id = aws_subnet.part1_private1.id
}

resource "aws_route_table_association" "part1_private2" {
  route_table_id = aws_route_table.part1_nat.id
  subnet_id = aws_subnet.part1_private2.id
}

resource "aws_internet_gateway" "part1" {
  vpc_id = aws_vpc.part1.id
}

resource "aws_route_table" "part1_igw" {
  vpc_id = aws_vpc.part1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.part1.id
  }
}

resource "aws_route_table_association" "part1_public1" {
  route_table_id = aws_route_table.part1_igw.id
  subnet_id = aws_subnet.part1_public1.id
}

resource "aws_route_table_association" "part1_public2" {
  route_table_id = aws_route_table.part1_igw.id
  subnet_id = aws_subnet.part1_public2.id
}

resource "aws_security_group" "part1_public" {
  vpc_id = aws_vpc.part1.id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "part1_private" {
  vpc_id = aws_vpc.part1.id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = [aws_security_group.part1_public.id]
  }
}

resource "aws_key_pair" "part1" {
  public_key = file(var.public_key)
}

resource "aws_instance" "part1_public" {
  count = 2
  ami = var.centos8_ami_id
  instance_type = var.ec2_size
  vpc_security_group_ids = [aws_security_group.part1_public.id]
  subnet_id = aws_subnet.part1_public1.id
  key_name = aws_key_pair.part1.key_name
  associate_public_ip_address = true

}

data "aws_ami" "hello_world_centos8" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "tag:Name"
    values = ["hello-world-centos8"]
  }
}

resource "aws_instance" "part1_private" {
  count = 2
  ami = data.aws_ami.hello_world_centos8.id
  instance_type = var.ec2_size
  vpc_security_group_ids = [aws_security_group.part1_private.id]
  subnet_id = aws_subnet.part1_private2.id
  key_name = aws_key_pair.part1.key_name
}
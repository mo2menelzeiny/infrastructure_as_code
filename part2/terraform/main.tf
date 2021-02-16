terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.28.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region = var.region
}

data "aws_availability_zones" "part2" {}

resource "aws_vpc" "part2" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "part2_public" {
  count = length(data.aws_availability_zones.part2.names)
  vpc_id = aws_vpc.part2.id
  cidr_block = "10.1.${10+count.index}.0/28"
  availability_zone = data.aws_availability_zones.part2.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "part2_private" {
  count = length(data.aws_availability_zones.part2.names)
  vpc_id = aws_vpc.part2.id
  cidr_block = "10.1.${20+count.index}.0/28"
  availability_zone = data.aws_availability_zones.part2.names[count.index]
}

resource "aws_eip" "part2" {
  vpc = true
}

resource "aws_nat_gateway" "part2" {
  subnet_id = aws_subnet.part2_public[0].id
  allocation_id = aws_eip.part2.id
}

resource "aws_route_table" "part2_nat" {
  vpc_id = aws_vpc.part2.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.part2.id
  }
}

resource "aws_route_table_association" "part2_private" {
  count = length(data.aws_availability_zones.part2.names)
  route_table_id = aws_route_table.part2_nat.id
  subnet_id = aws_subnet.part2_private[count.index].id
}

resource "aws_internet_gateway" "part2" {
  vpc_id = aws_vpc.part2.id
}

resource "aws_route_table" "part2_igw" {
  vpc_id = aws_vpc.part2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.part2.id
  }
}

resource "aws_route_table_association" "part2_public" {
  count = length(data.aws_availability_zones.part2.names)
  route_table_id = aws_route_table.part2_igw.id
  subnet_id = aws_subnet.part2_public[count.index].id
}


resource "aws_security_group" "part2_alb" {
  vpc_id = aws_vpc.part2.id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "part2_asg" {
  vpc_id = aws_vpc.part2.id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = [aws_security_group.part2_alb.id]
  }
}

resource "aws_lb" "part2" {
  subnets = aws_subnet.part2_public.*.id
  security_groups = [aws_security_group.part2_alb.id]
}

resource "aws_lb_listener" "part2" {
  load_balancer_arn = aws_lb.part2.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code = "200"
    }
  }
}

resource "aws_lb_target_group" "par2" {
  vpc_id = aws_vpc.part2.id
  port = 80
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "part2" {
  listener_arn = aws_lb_listener.part2.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.par2.arn
  }

  condition {
    path_pattern {
      values = ["/hello"]
    }
  }
}

data "aws_ami" "hello_centos8" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "tag:Name"
    values = ["hello-centos8"]
  }
}

resource "aws_launch_template" "part2" {
  image_id = data.aws_ami.hello_centos8.id
  instance_type = var.ec2_size
  vpc_security_group_ids = [aws_security_group.part2_asg.id]
}

resource "aws_autoscaling_group" "part2" {
  name = "part2-asg"
  vpc_zone_identifier = aws_subnet.part2_private.*.id
  target_group_arns = aws_lb_target_group.par2.*.arn
  max_size = 1
  min_size = 1
  desired_capacity = 1

  launch_template {
    id = aws_launch_template.part2.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_schedule" "part2_up" {
  autoscaling_group_name = aws_autoscaling_group.part2.name
  scheduled_action_name = "scale-up"
  max_size = 3
  min_size = 1
  desired_capacity = 3
  recurrence = "0 7 * * *"
}

resource "aws_autoscaling_schedule" "part2_down" {
  autoscaling_group_name = aws_autoscaling_group.part2.name
  scheduled_action_name = "scale-down"
  max_size = 1
  min_size = 1
  desired_capacity = 1
  recurrence = "0 17 * * *"
}

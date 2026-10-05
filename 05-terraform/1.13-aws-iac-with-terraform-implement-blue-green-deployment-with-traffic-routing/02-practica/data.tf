data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "public_1" {
  vpc_id = data.aws_vpc.existing.id

  filter {
    name   = "tag:Name"
    values = [var.public_subnet_1_name]
  }
}

data "aws_subnet" "public_2" {
  vpc_id = data.aws_vpc.existing.id

  filter {
    name   = "tag:Name"
    values = [var.public_subnet_2_name]
  }
}

data "aws_security_group" "ssh" {
  name   = var.sg_ssh_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_security_group" "http" {
  name   = var.sg_http_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_security_group" "lb" {
  name   = var.sg_lb_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

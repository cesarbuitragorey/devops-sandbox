data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.existing.id

  filter {
    name   = "tag:Name"
    values = [var.public_subnet_name]
  }
}

data "aws_security_group" "existing" {
  vpc_id = data.aws_vpc.existing.id

  filter {
    name   = "tag:Name"
    values = [var.security_group_name]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

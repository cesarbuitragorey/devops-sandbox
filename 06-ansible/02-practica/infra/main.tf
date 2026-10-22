provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = sort(data.aws_subnets.default.ids)[0]
}

data "aws_ami" "lab" {
  most_recent = true
  owners      = [var.ami_owner_id]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  machines = {
    for name, m in var.machines : name => {
      fqdn = "${name}.${var.domain}"
      ip   = cidrhost(data.aws_subnet.selected.cidr_block, m.host_number)
    }
  }
}

resource "aws_key_pair" "lab" {
  key_name   = "${var.name_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))
  tags       = var.tags
}

resource "aws_security_group" "lab" {
  name        = "${var.name_prefix}-sg"
  description = "Ansible lab: SSH and collectd exporter from the allowed CIDR, all traffic between the lab machines"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from the allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "collectd Prometheus exporter from the allowed CIDR"
    from_port   = var.collectd_port
    to_port     = var.collectd_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "All traffic between the lab machines"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg" })
}

resource "aws_instance" "lab" {
  for_each = local.machines

  ami                         = data.aws_ami.lab.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  private_ip                  = each.value.ip
  associate_public_ip_address = true
  key_name                    = aws_key_pair.lab.key_name
  vpc_security_group_ids      = [aws_security_group.lab.id]

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    fqdn                  = each.value.fqdn
    machines              = local.machines
    is_control            = each.key == "control"
    ssh_user              = var.ssh_user
    private_key_file_name = var.private_key_file_name
  })
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.tags, { Name = each.value.fqdn })
}

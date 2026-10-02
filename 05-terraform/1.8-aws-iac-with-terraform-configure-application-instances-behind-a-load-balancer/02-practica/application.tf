locals {
  common_tags = {
    Terraform = "true"
    Project   = var.project_id
  }
}

data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "public_a" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.public_subnet_a_cidr
}

data "aws_subnet" "public_b" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.public_subnet_b_cidr
}

data "aws_security_group" "ec2" {
  name   = var.ec2_sg_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_security_group" "http" {
  name   = var.http_sg_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_security_group" "lb" {
  name   = var.lb_sg_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_ssm_parameter" "al2023_ami" {
  name = var.ami_ssm_parameter_name
}

resource "aws_launch_template" "this" {
  name          = var.launch_template_name
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [data.aws_security_group.ec2.id, data.aws_security_group.http.id]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    dnf update -y
    dnf install -y httpd jq
    systemctl enable httpd
    systemctl start httpd

    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

    echo "<html><body><h1>Hello from instance $INSTANCE_ID with private IP $PRIVATE_IP</h1></body></html>" > /var/www/html/index.html
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    path = "/"
  }

  tags = local.common_tags
}

resource "aws_lb" "this" {
  name               = var.lb_name
  load_balancer_type = "application"
  internal           = false
  security_groups    = [data.aws_security_group.lb.id]
  subnets            = [data.aws_subnet.public_a.id, data.aws_subnet.public_b.id]

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = local.common_tags
}

resource "aws_autoscaling_group" "this" {
  name                = var.asg_name
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  vpc_zone_identifier = [data.aws_subnet.public_a.id, data.aws_subnet.public_b.id]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

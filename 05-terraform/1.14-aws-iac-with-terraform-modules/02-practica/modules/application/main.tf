data "aws_ami" "al2023" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

resource "aws_launch_template" "this" {
  name          = var.launch_template_name
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = var.instance_security_group_ids
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd

    COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    COMPUTE_INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

    echo "This message was generated on instance $COMPUTE_INSTANCE_ID with the following UUID $COMPUTE_MACHINE_UUID" > /var/www/html/index.html
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = var.tags
}

resource "aws_lb" "this" {
  name               = var.lb_name
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.lb_security_group_id]
  subnets            = var.subnet_ids

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "this" {
  name                = var.asg_name
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.tags

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

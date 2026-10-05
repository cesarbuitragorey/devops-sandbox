locals {
  common_tags = {
    Terraform = "true"
    Project   = var.project_id
  }
}

resource "aws_lb_target_group" "blue" {
  name     = var.blue_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    path = "/"
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "green" {
  name     = var.green_tg_name
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
  subnets            = [data.aws_subnet.public_1.id, data.aws_subnet.public_2.id]

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.blue_weight
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.green_weight
      }
    }
  }

  tags = local.common_tags
}

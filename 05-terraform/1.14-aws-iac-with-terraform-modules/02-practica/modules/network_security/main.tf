resource "aws_security_group" "ssh" {
  name   = var.ssh_sg_name
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = var.ssh_sg_name })
}

resource "aws_security_group" "public_http" {
  name   = var.public_http_sg_name
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = var.public_http_sg_name })
}

resource "aws_security_group" "private_http" {
  name   = var.private_http_sg_name
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = var.private_http_sg_name })
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
}

resource "aws_security_group_rule" "public_http_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.public_http.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
}

resource "aws_security_group_rule" "private_http_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_http.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http.id
}

# Terraform removes the default allow-all egress rule from security groups it
# creates, so outbound traffic must be re-declared explicitly: instances need it
# to install packages and the load balancer needs it to reach the instances.
resource "aws_security_group_rule" "egress_all" {
  for_each = {
    ssh          = aws_security_group.ssh.id
    public_http  = aws_security_group.public_http.id
    private_http = aws_security_group.private_http.id
  }

  type              = "egress"
  security_group_id = each.value
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.internet_cidr]
}

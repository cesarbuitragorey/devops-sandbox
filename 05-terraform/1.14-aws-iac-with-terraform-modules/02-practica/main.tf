provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  vpc_name              = var.vpc_name
  vpc_cidr              = var.vpc_cidr
  internet_gateway_name = var.internet_gateway_name
  route_table_name      = var.route_table_name
  internet_cidr         = var.internet_cidr
  public_subnets        = var.public_subnets
  tags                  = var.common_tags
}

module "network_security" {
  source = "./modules/network_security"

  vpc_id               = module.network.vpc_id
  allowed_ip_range     = var.allowed_ip_range
  internet_cidr        = var.internet_cidr
  ssh_sg_name          = var.ssh_sg_name
  public_http_sg_name  = var.public_http_sg_name
  private_http_sg_name = var.private_http_sg_name
  tags                 = var.common_tags
}

module "application" {
  source = "./modules/application"

  vpc_id                      = module.network.vpc_id
  subnet_ids                  = module.network.public_subnet_ids
  instance_security_group_ids = [module.network_security.ssh_sg_id, module.network_security.private_http_sg_id]
  lb_security_group_id        = module.network_security.public_http_sg_id
  ami_owner                   = var.ami_owner
  ami_name_pattern            = var.ami_name_pattern
  instance_type               = var.instance_type
  launch_template_name        = var.launch_template_name
  asg_name                    = var.asg_name
  lb_name                     = var.lb_name
  target_group_name           = var.target_group_name
  asg_desired_capacity        = var.asg_desired_capacity
  asg_min_size                = var.asg_min_size
  asg_max_size                = var.asg_max_size
  tags                        = var.common_tags
}

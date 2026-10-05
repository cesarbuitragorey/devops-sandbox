aws_region = "eu-west-1"

common_tags = {
  Terraform = "true"
  Project   = "cmtr-iacp1ebx"
}

vpc_name              = "cmtr-iacp1ebx-vpc"
vpc_cidr              = "10.10.0.0/16"
internet_gateway_name = "cmtr-iacp1ebx-igw"
route_table_name      = "cmtr-iacp1ebx-rt"
internet_cidr         = "0.0.0.0/0"

public_subnets = {
  a = {
    name              = "cmtr-iacp1ebx-subnet-public-a"
    cidr_block        = "10.10.1.0/24"
    availability_zone = "eu-west-1a"
  }
  b = {
    name              = "cmtr-iacp1ebx-subnet-public-b"
    cidr_block        = "10.10.3.0/24"
    availability_zone = "eu-west-1b"
  }
  c = {
    name              = "cmtr-iacp1ebx-subnet-public-c"
    cidr_block        = "10.10.5.0/24"
    availability_zone = "eu-west-1c"
  }
}

allowed_ip_range = ["18.153.146.156/32", "190.255.115.133/32"]

ssh_sg_name          = "cmtr-iacp1ebx-ssh-sg"
public_http_sg_name  = "cmtr-iacp1ebx-public-http-sg"
private_http_sg_name = "cmtr-iacp1ebx-private-http-sg"

ami_owner        = "amazon"
ami_name_pattern = "al2023-ami-2023.*-x86_64"
instance_type    = "t3.micro"

launch_template_name = "cmtr-iacp1ebx-template"
asg_name             = "cmtr-iacp1ebx-asg"
lb_name              = "cmtr-iacp1ebx-lb"
target_group_name    = "cmtr-iacp1ebx-tg"

asg_desired_capacity = 2
asg_min_size         = 2
asg_max_size         = 2

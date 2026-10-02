aws_region = "eu-west-1"
project_id = "cmtr-iacp1ebx"

vpc_name             = "cmtr-iacp1ebx-vpc"
public_subnet_a_cidr = "10.0.1.0/24"
public_subnet_b_cidr = "10.0.3.0/24"

ec2_sg_name           = "cmtr-iacp1ebx-ec2_sg"
http_sg_name          = "cmtr-iacp1ebx-http_sg"
lb_sg_name            = "cmtr-iacp1ebx-sglb"
instance_profile_name = "cmtr-iacp1ebx-instance_profile"
key_pair_name         = "cmtr-iacp1ebx-keypair"

ami_ssm_parameter_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
instance_type          = "t3.micro"

launch_template_name = "cmtr-iacp1ebx-template"
asg_name             = "cmtr-iacp1ebx-asg"
lb_name              = "cmtr-iacp1ebx-loadbalancer"
target_group_name    = "cmtr-iacp1ebx-tg"

asg_desired_capacity = 2
asg_min_size         = 1
asg_max_size         = 2

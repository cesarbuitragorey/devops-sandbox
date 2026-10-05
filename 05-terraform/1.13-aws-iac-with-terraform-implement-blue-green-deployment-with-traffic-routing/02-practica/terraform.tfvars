aws_region = "eu-west-1"
project_id = "cmtr-iacp1ebx"

vpc_name             = "cmtr-iacp1ebx-vpc"
public_subnet_1_name = "cmtr-iacp1ebx-public-subnet1"
public_subnet_2_name = "cmtr-iacp1ebx-public-subnet2"

sg_ssh_name  = "cmtr-iacp1ebx-sg-ssh"
sg_http_name = "cmtr-iacp1ebx-sg-http"
sg_lb_name   = "cmtr-iacp1ebx-sg-lb"

ami_owner        = "amazon"
ami_name_pattern = "al2023-ami-2023.*-x86_64"
instance_type    = "t3.micro"

lb_name             = "cmtr-iacp1ebx-lb"
blue_tg_name        = "cmtr-iacp1ebx-blue-tg"
green_tg_name       = "cmtr-iacp1ebx-green-tg"
blue_template_name  = "cmtr-iacp1ebx-blue-template"
green_template_name = "cmtr-iacp1ebx-green-template"
blue_asg_name       = "cmtr-iacp1ebx-blue-asg"
green_asg_name      = "cmtr-iacp1ebx-green-asg"

blue_page_heading  = "Blue Environment"
green_page_heading = "Green Environment"

asg_desired_capacity = 1
asg_min_size         = 1
asg_max_size         = 2

blue_weight  = 100
green_weight = 0

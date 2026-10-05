variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
}

variable "project_id" {
  description = "Project identifier used for the Project tag."
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the pre-created VPC."
  type        = string
}

variable "public_subnet_1_name" {
  description = "Name tag of the first pre-created public subnet."
  type        = string
}

variable "public_subnet_2_name" {
  description = "Name tag of the second pre-created public subnet."
  type        = string
}

variable "sg_ssh_name" {
  description = "Name of the pre-created security group that allows SSH access to instances."
  type        = string
}

variable "sg_http_name" {
  description = "Name of the pre-created security group that allows HTTP access to instances."
  type        = string
}

variable "sg_lb_name" {
  description = "Name of the pre-created security group that allows HTTP access to the load balancer."
  type        = string
}

variable "ami_owner" {
  description = "Owner of the AMI to discover."
  type        = string
}

variable "ami_name_pattern" {
  description = "Name pattern used to discover the latest Amazon Linux 2023 AMI."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by both launch templates."
  type        = string
}

variable "lb_name" {
  description = "Name to assign to the Application Load Balancer."
  type        = string
}

variable "blue_tg_name" {
  description = "Name to assign to the Blue target group."
  type        = string
}

variable "green_tg_name" {
  description = "Name to assign to the Green target group."
  type        = string
}

variable "blue_template_name" {
  description = "Name to assign to the Blue launch template."
  type        = string
}

variable "green_template_name" {
  description = "Name to assign to the Green launch template."
  type        = string
}

variable "blue_asg_name" {
  description = "Name to assign to the Blue Auto Scaling group."
  type        = string
}

variable "green_asg_name" {
  description = "Name to assign to the Green Auto Scaling group."
  type        = string
}

variable "blue_page_heading" {
  description = "Heading displayed by the web page served from the Blue environment."
  type        = string
}

variable "green_page_heading" {
  description = "Heading displayed by the web page served from the Green environment."
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in each Auto Scaling group."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances in each Auto Scaling group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in each Auto Scaling group."
  type        = number
}

variable "blue_weight" {
  description = "Traffic weight sent by the load balancer listener to the Blue target group."
  type        = number
}

variable "green_weight" {
  description = "Traffic weight sent by the load balancer listener to the Green target group."
  type        = number
}

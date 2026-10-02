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

variable "public_subnet_a_cidr" {
  description = "CIDR block of the pre-created public subnet A."
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block of the pre-created public subnet B."
  type        = string
}

variable "ec2_sg_name" {
  description = "Name of the pre-created security group that allows SSH access to EC2 instances."
  type        = string
}

variable "http_sg_name" {
  description = "Name of the pre-created security group that allows HTTP access to EC2 instances."
  type        = string
}

variable "lb_sg_name" {
  description = "Name of the pre-created security group that allows HTTP access to the load balancer."
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the pre-created IAM instance profile for the EC2 instances."
  type        = string
}

variable "key_pair_name" {
  description = "Name of the pre-created key pair for SSH access to the EC2 instances."
  type        = string
}

variable "ami_ssm_parameter_name" {
  description = "SSM Parameter Store path that resolves to the latest Amazon Linux 2023 AMI ID."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the Launch Template."
  type        = string
}

variable "launch_template_name" {
  description = "Name to assign to the Launch Template."
  type        = string
}

variable "asg_name" {
  description = "Name to assign to the Auto Scaling Group."
  type        = string
}

variable "lb_name" {
  description = "Name to assign to the Application Load Balancer."
  type        = string
}

variable "target_group_name" {
  description = "Name to assign to the load balancer target group."
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
}

variable "aws_region" {
  description = "The AWS region where resources are located."
  type        = string
}

variable "project_id" {
  description = "The project identifier used for tagging."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC to discover."
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet to discover."
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group to discover."
  type        = string
}

variable "instance_name" {
  description = "Name to assign to the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type to launch."
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

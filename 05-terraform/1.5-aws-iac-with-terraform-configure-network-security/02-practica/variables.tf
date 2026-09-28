variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
}

variable "allowed_ip_range" {
  description = "List of IP ranges (CIDR) allowed to reach the infrastructure over SSH, HTTP and ICMP."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the pre-created VPC."
  type        = string
}

variable "public_instance_id" {
  description = "ID of the pre-created public EC2 instance."
  type        = string
}

variable "private_instance_id" {
  description = "ID of the pre-created private EC2 instance."
  type        = string
}

variable "ssh_sg_name" {
  description = "Name to assign to the SSH security group."
  type        = string
}

variable "public_http_sg_name" {
  description = "Name to assign to the public HTTP security group."
  type        = string
}

variable "private_http_sg_name" {
  description = "Name to assign to the private HTTP security group."
  type        = string
}

variable "project_tag" {
  description = "Value for the Project tag applied to all created security groups."
  type        = string
}

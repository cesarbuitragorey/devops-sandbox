variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
}

variable "common_tags" {
  description = "Tags applied to every resource created by the modules."
  type        = map(string)
}

variable "vpc_name" {
  description = "Name to assign to the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "internet_gateway_name" {
  description = "Name to assign to the Internet Gateway."
  type        = string
}

variable "route_table_name" {
  description = "Name to assign to the public route table."
  type        = string
}

variable "internet_cidr" {
  description = "CIDR block that represents all internet traffic (default route and outbound security group rules)."
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets to create, keyed by a short identifier. Each entry defines the subnet name, CIDR block and Availability Zone."
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "allowed_ip_range" {
  description = "List of IP ranges (CIDR) allowed to reach the SSH and public HTTP security groups."
  type        = list(string)
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

variable "ami_owner" {
  description = "Owner of the AMI to discover."
  type        = string
}

variable "ami_name_pattern" {
  description = "Name pattern used to discover the latest Amazon Linux 2023 AMI."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the launch template."
  type        = string
}

variable "launch_template_name" {
  description = "Name to assign to the launch template."
  type        = string
}

variable "asg_name" {
  description = "Name to assign to the Auto Scaling group."
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
  description = "Desired number of instances in the Auto Scaling group."
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling group."
  type        = number
}

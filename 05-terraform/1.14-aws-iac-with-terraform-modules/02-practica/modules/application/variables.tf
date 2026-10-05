variable "vpc_id" {
  description = "ID of the VPC where the target group is created."
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets used by the load balancer and the Auto Scaling group."
  type        = list(string)
}

variable "instance_security_group_ids" {
  description = "IDs of the security groups attached to the EC2 instances."
  type        = list(string)
}

variable "lb_security_group_id" {
  description = "ID of the security group attached to the load balancer."
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

variable "tags" {
  description = "Tags applied to every resource created by this module."
  type        = map(string)
}

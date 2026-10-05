variable "vpc_id" {
  description = "ID of the VPC where the security groups are created."
  type        = string
}

variable "allowed_ip_range" {
  description = "List of IP ranges (CIDR) allowed to reach the SSH and public HTTP security groups."
  type        = list(string)
}

variable "internet_cidr" {
  description = "CIDR block that represents all outbound traffic in the egress rules."
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

variable "tags" {
  description = "Tags applied to every resource created by this module."
  type        = map(string)
}

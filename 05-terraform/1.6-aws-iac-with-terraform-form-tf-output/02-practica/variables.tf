variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
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
  description = "Name to assign to the Internet Gateway attached to the VPC."
  type        = string
}

variable "route_table_name" {
  description = "Name to assign to the public route table."
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

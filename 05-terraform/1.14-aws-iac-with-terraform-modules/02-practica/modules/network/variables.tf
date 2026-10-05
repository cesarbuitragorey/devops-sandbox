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
  description = "CIDR block that represents all internet-bound traffic in the public route table."
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

variable "tags" {
  description = "Tags applied to every resource created by this module."
  type        = map(string)
}

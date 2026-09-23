variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
}

variable "ssh_key" {
  description = "Provides custom public SSH key."
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the pre-created VPC to reference via a data source."
  type        = string
}

variable "security_group_name" {
  description = "Name of the pre-created security group to reference via a data source."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone of the pre-created public subnet to launch the EC2 instance in."
  type        = string
}

variable "key_pair_name" {
  description = "Name to assign to the AWS key pair resource."
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

variable "project_tag" {
  description = "Value for the Project tag applied to all created resources."
  type        = string
}

variable "id_tag" {
  description = "Value for the ID tag applied to all created resources."
  type        = string
}

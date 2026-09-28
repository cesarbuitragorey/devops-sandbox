variable "aws_region" {
  description = "AWS region for the resources."
  type        = string
}

variable "project_id" {
  description = "Project identifier used for tagging."
  type        = string
}

variable "state_bucket" {
  description = "Name of the S3 bucket that stores the remote Terraform state of the Landing Zone."
  type        = string
}

variable "state_key" {
  description = "S3 key path to the remote Terraform state file of the Landing Zone."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type to launch."
  type        = string
}

variable "ami_ssm_parameter_name" {
  description = "SSM Parameter Store path that resolves to the latest AMI ID to use for the EC2 instance."
  type        = string
}

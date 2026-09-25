variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique name for the S3 bucket."
  type        = string
}

variable "project_tag" {
  description = "Value for the Project tag applied to the S3 bucket."
  type        = string
}

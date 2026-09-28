variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
}

variable "bucket_name" {
  description = "Name of the pre-created S3 bucket referenced by the IAM policy."
  type        = string
}

variable "iam_group_name" {
  description = "Name to assign to the IAM group."
  type        = string
}

variable "iam_policy_name" {
  description = "Name to assign to the custom IAM policy."
  type        = string
}

variable "iam_role_name" {
  description = "Name to assign to the IAM role."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name to assign to the IAM instance profile."
  type        = string
}

variable "project_tag" {
  description = "Value for the Project tag applied to all taggable created resources."
  type        = string
}

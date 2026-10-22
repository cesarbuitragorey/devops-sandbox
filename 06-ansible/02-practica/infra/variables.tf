variable "aws_region" {
  description = "AWS region where the lab environment is created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for the names of the lab resources."
  type        = string
}

variable "domain" {
  description = "DNS domain appended to the machine names to build their FQDN (control.<domain>, node1.<domain>, ...)."
  type        = string
}

variable "machines" {
  description = "Lab machines keyed by short name. host_number is the host part inside the subnet CIDR and gives each machine a fixed private IP."
  type = map(object({
    host_number = number
  }))
}

variable "instance_type" {
  description = "EC2 instance type for all machines (t3.micro is free-tier eligible and meets the 1 vCPU requirement)."
  type        = string
}

variable "root_volume_size" {
  description = "Size in GiB of the root volume of every machine."
  type        = number
}

variable "ami_owner_id" {
  description = "AWS account ID that publishes the AMI (125523088429 is the official CentOS account)."
  type        = string
}

variable "ami_name_pattern" {
  description = "Name pattern used to find the latest AMI."
  type        = string
}

variable "ssh_user" {
  description = "Default SSH user of the AMI."
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key registered as the EC2 key pair."
  type        = string
}

variable "private_key_file_name" {
  description = "File name under ~/.ssh on the control node where the private key is expected (used in the generated ~/.ssh/config)."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to reach SSH (22) and the collectd exporter (9103) from the internet."
  type        = string
}

variable "collectd_port" {
  description = "Port of the collectd Prometheus exporter."
  type        = number
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
}

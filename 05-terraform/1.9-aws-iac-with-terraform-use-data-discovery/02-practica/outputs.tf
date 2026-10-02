output "instance_id" {
  description = "ID of the created EC2 instance."
  value       = aws_instance.this.id
}

output "discovered_ami_id" {
  description = "ID of the Amazon Linux 2023 AMI discovered by the data source."
  value       = data.aws_ami.al2023.id
}

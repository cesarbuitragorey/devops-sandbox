output "instance_public_ip" {
  description = "Public IP address of the EC2 instance, used to connect via SSH."
  value       = aws_instance.this.public_ip
}

output "key_pair_name" {
  description = "Name of the AWS key pair registered for SSH access."
  value       = aws_key_pair.this.key_name
}

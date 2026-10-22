output "public_ips" {
  description = "Public IP of each lab machine."
  value       = { for name, i in aws_instance.lab : name => i.public_ip }
}

output "private_ips" {
  description = "Fixed private IP of each lab machine (the ones written in /etc/hosts)."
  value       = { for name, i in aws_instance.lab : name => i.private_ip }
}

output "ami_id" {
  description = "AMI used by the lab machines."
  value       = data.aws_ami.lab.id
}

output "ssh_control" {
  description = "SSH command to enter the control node from the workstation."
  value       = "ssh -i ${trimsuffix(var.public_key_path, ".pub")} ${var.ssh_user}@${aws_instance.lab["control"].public_ip}"
}

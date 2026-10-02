output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "launch_template_id" {
  description = "ID of the Launch Template."
  value       = aws_launch_template.this.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.this.name
}

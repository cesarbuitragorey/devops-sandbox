output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "blue_target_group_arn" {
  description = "ARN of the Blue target group."
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of the Green target group."
  value       = aws_lb_target_group.green.arn
}

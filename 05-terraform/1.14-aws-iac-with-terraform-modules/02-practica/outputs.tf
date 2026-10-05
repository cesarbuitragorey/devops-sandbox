output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer, taken from the application module."
  value       = module.application.lb_dns_name
}

output "vpc_id" {
  description = "ID of the VPC created by the network module."
  value       = module.network.vpc_id
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Map of public subnet identifiers (as defined in var.public_subnets) to their resulting subnet IDs."
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "route_table_id" {
  description = "ID of the public route table associated with all public subnets."
  value       = aws_route_table.public.id
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Map of public subnet identifiers (as defined in var.public_subnets) to their resulting subnet IDs."
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "public_subnet_cidr_block" {
  description = "Map of public subnet identifiers to their CIDR blocks."
  value       = { for k, s in aws_subnet.public : k => s.cidr_block }
}

output "public_subnet_availability_zone" {
  description = "Map of public subnet identifiers to their Availability Zones."
  value       = { for k, s in aws_subnet.public : k => s.availability_zone }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "routing_table_id" {
  description = "ID of the public route table associated with all public subnets."
  value       = aws_route_table.public.id
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, ordered by their key in the public_subnets input."
  value       = [for key in sort(keys(aws_subnet.public)) : aws_subnet.public[key].id]
}

output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "ID of created VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "List of public subnet ids"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "List of private subnet ids"
}

output "database_subnet_ids" {
  value       = aws_subnet.database_subnet[*].id
  description = "List of database subnet ids"
}

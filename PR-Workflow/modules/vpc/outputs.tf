output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public client subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private middle-tier subnet"
  value       = aws_subnet.private.id
}

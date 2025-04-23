output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "eip_allocation_id" {
  description = "Elastic IP allocation ID for the NAT Gateway"
  value       = aws_eip.this[0].id
}
output "public_sg_id" {
  description = "The ID of the public security group"
  value       = aws_security_group.public_sg.id
}

output "private_sg_id" {
  description = "The ID of the private security group"
  value       = aws_security_group.private_sg.id
}

output "public_lb_sg_id" {
  description = "The ID of the public alb security group"
  value       = aws_security_group.public_lb_sg.id
}

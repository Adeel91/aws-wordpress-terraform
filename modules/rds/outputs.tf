output "rds_instance_endpoint" {
  description = "The endpoint of the RDS MariaDB instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS MariaDB instance"
  value       = aws_db_instance.this.id
}
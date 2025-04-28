output "rds_instance_endpoint" {
  description = "The endpoint of the RDS MariaDB instance"
  value       = aws_db_instance.mariadb_instance.endpoint
}
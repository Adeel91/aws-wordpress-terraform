variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "db_name" {
  description = "The name of the MariaDB database"
  type        = string
}

variable "db_username" {
  description = "The username for the MariaDB database"
  type        = string
}

variable "db_password" {
  description = "The password for the MariaDB database"
  type        = string
  sensitive   = true
}

variable "private_subnet_ids" {
  description = "The list of private subnet IDs for RDS deployment"
  type        = list(string)
}

variable "security_group_id" {
  description = "The security group ID for the RDS instance"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

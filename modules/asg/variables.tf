variable "project_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "private_sg_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "db_name" {
  description = "RDS/WordPress Database name"
  type        = string
}

variable "db_username" {
  description = "RDS/WordPress Database username"
  type        = string
}

variable "db_password" {
  description = "RDS/WordPress Database password"
  type        = string
}

variable "admin_email" {
  description = "WordPress admin email"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS Database endpoint"
  type        = string
}
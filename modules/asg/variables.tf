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
  description = "RDS Database endpoint"
  type        = string
}

variable "db_username" {
  description = "RDS Database endpoint"
  type        = string
}

variable "db_password" {
  description = "RDS Database endpoint"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS Database endpoint"
  type        = string
}
variable "aws_ami" {
  description = "Latest Amazon Linux 2 AMI"
  type        = string
}

variable "instance_type" {
  description = "EC2 machine instance type"
  type        = string
}

variable "public_subnet1_id" {
  description = "The CIDR block for the public subnet in AZ1"
  type        = string
  default     = null
}

variable "private_subnet1_id" {
  description = "The CIDR block for the private subnet in AZ1"
  type        = string
  default     = null
}

variable "private_subnet2_id" {
  description = "The CIDR block for the private subnet in AZ2"
  type        = string
  default     = null
}

variable "public_sg_id" {
  description = "The seucirty group for the instance in public subnet"
  type        = string
}

variable "private_sg_id" {
  description = "The seucirty group for the instance in private subnet"
  type        = string
}

variable "key_name" {
  description = "The SSH key name for EC2 instances"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
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

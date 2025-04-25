variable "vpc_id" {
  description = "The ID of the VPC to associate with the security group"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnets"
  type        = string
  default     = ""
}

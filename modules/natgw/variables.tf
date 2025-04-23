variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where the NAT Gateway will be placed"
  type        = string
}

variable "create_eip" {
  description = "Whether to create an Elastic IP for the NAT Gateway"
  type        = bool
  default     = true
}
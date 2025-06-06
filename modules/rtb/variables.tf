variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs to associate with the route table"
  type        = map(string)
}

variable "is_public" {
  description = "Whether this is a public route table"
  type        = bool
}

variable "igw_id" {
  description = "Internet Gateway ID for public route table"
  type        = string
  default     = null
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for private subnets"
  type        = string
  default     = null
}
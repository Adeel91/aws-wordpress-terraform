# Create variables for Subnets
variable "vpc_id" {
  description = "ID of the VPC to associate with the subnet"
  type        = string
}

variable "subnet_name" {
  description = "Name tag for the subnet"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = list(string)
}

variable "azs" {
  description = "Availability zone for the subnet"
  type        = list(string)
}

variable "is_public" {
  description = "Whether the subnet is public or private"
  type        = bool
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
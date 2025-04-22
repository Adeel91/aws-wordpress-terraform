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
  default     = [
    "10.0.0.0/24",  # First public subnet
    "10.0.1.0/24",  # Second public subnet
    "10.0.2.0/24",  # First private subnet
    "10.0.3.0/24"   # Second private subnet
  ]
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
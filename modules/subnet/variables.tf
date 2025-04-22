# Create variables for Subnets
variable "vpc_id" {
  description = "ID of the VPC to associate with the subnet"
  type        = string
}

variable "subnet_name" {
  description = "Name tag for the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "azs" {
  description = "Availability zone for the subnet"
  type        = string
}

variable "is_public" {
  description = "Whether the subnet is public or private"
  type        = bool
}
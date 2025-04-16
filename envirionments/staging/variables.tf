variable "vpc_name" {
  description = "Defaut VPC name"
  type        = string
}

# Public Subnet Settings
variable "public_subnet_name" {
  description = "Name tag for the subnet"
  type        = string
}

variable "public_cidr_block" {
  description = "Public CIDR block"
  type        = string
}

# Private Subnet Settings
variable "private_subnet_name" {
  description = "Defaut VPC name"
  type        = string
}

variable "private_cidr_block" {
  description = "Private CIDR block"
  type        = string
}
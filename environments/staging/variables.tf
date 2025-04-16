variable "vpc_name" {
  description = "Defaut VPC name"
  type        = string
  default     = ""
}

# Public Subnet Settings
variable "public_subnet_name" {
  description = "Name tag for the subnet"
  type        = string
  default     = ""
}

variable "public_cidr_block" {
  description = "Public CIDR block"
  type        = string
  default     = ""
}

# Private Subnet Settings
variable "private_subnet_name" {
  description = "Defaut VPC name"
  type        = string
  default     = ""
}

variable "private_cidr_block" {
  description = "Private CIDR block"
  type        = string
  default     = ""
}
variable "vpc_name" {
  description   = "Defaut VPC name"
  type          = string
  default       = "wordpress-vpc"
}

# Public Subnet Settings
variable "public_subnet_name" {
  description   = "Name tag for the subnet"
  type          = string
  default       = "public-subnet"
}

variable "public_cidr_block" {
  description   = "Public CIDR block"
  type          = string
  default       = "10.0.1.0/24"
}

# Private Subnet Settings
variable "private_subnet_name" {
  description   = "Defaut VPC name"
  type          = string
  default       = "private-subnet"
}

variable "private_cidr_block" {
  description   = "Private CIDR block"
  type          = string
  default       = "10.0.2.0/24"
}

variable "azs" {
  description = "Availability zones in which to create subnets"
  type        = string
  default     = ["us-west-2a", "us-west-2b"]
}
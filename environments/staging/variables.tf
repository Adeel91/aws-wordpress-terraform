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

# Private Subnet Settings
variable "private_subnet_name" {
  description   = "Defaut VPC name"
  type          = string
  default       = "private-subnet"
}

variable "azs" {
  description = "Availability zones in which to create subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "wordpress"
}
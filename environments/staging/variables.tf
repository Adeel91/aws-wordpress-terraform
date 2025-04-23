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
  description   = "Availability zones in which to create subnets"
  type          = list(string)
  default       = ["us-west-2a", "us-west-2b"]
}

variable "project_name" {
  description   = "Project name"
  type          = string
}

variable "subnet_cidr_blocks" {
  description   = "CIDR blocks for subnets"
  type          = list(string)
  default       = ["10.0.0.0/24", "10.0.1.0/24"]
}
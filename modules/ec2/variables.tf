variable "public_subnet_cidr_az1" {
  description = "The CIDR block for the public subnet in AZ1"
  type = string
  default = null
}

variable "private_subnet_cidr_az1" {
  description = "The CIDR block for the private subnet in AZ1"
  type = string
  default = null
}

variable "private_subnet_cidr_az2" {
  description = "The CIDR block for the private subnet in AZ2"
  type = string
  default = null
}

variable "key_name" {
  description = "The SSH key name for EC2 instances"
  type = string
  default = "vockey"
}

variable "project_name" {
  description = "Project name"
  type = string
}

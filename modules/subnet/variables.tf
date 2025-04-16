# Create variables for Subnets
variable "vpc_id" {
  description = "ID of the VPC to associate with the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default   = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-west-2a"
}

variable "subnet_name" {
  description = "Name tag for the subnet"
  type        = string
  default     = "public-subnet"
}
variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "sg_name" {
  description = "Short name to uniquely identify the SG"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

# variable "vpc_id" {
#   description = "The ID of the VPC to associate with the security group"
#   type        = string
# }

# variable "project_name" {
#   description = "Name of the project"
#   type        = string
# }

# variable "subnet_cidr" {
#   description = "CIDR block for the private subnets"
#   type        = list(string)
# }

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
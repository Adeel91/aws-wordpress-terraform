variable "project_name" {
  description = "Project name for resources"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to associate with the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the ALB is located"
  type        = string
}

variable "wordpress_az1_id" {
  description = "Instance ID of the WordPress EC2 instance in AZ1"
  type        = string
  default     = null
}

variable "wordpress_az2_id" {
  description = "Instance ID of the WordPress EC2 instance in AZ2"
  type        = string
  default     = null
}
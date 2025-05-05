variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  type        = string
}

variable "asg_name" {
  description = "Name of the WordPress ASG"
  type        = string
}

variable "rds_id" {
  description = "Identifier of the RDS instance"
  type        = string
}
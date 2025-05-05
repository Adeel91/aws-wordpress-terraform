variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "notification_email" {
  description = "Email address to receive alerts"
  type        = string
  default     = "your-email@example.com"
}
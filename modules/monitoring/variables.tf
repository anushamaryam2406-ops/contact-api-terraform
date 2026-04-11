variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "post_contact_function_name" {
  description = "POST Lambda function name from lambda module"
  type        = string
}

variable "get_messages_function_name" {
  description = "GET Lambda function name from lambda module"
  type        = string
}

variable "alert_email" {
  description = "Email to receive alarm notifications"
  type        = string
}

variable "error_threshold" {
  description = "Number of errors before alarm triggers"
  type        = number
  default     = 2
}

variable "alarm_period" {
  description = "Period in seconds for alarm evaluation"
  type        = number
  default     = 300
}

variable "duration_threshold" {
  description = "Lambda duration threshold in ms before alarm triggers"
  type        = number
  default     = 5000
}
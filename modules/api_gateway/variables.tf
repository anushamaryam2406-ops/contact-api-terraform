variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "post_contact_invoke_arn" {
  description = "Invoke ARN of POST Lambda from lambda module"
  type        = string
}

variable "get_messages_invoke_arn" {
  description = "Invoke ARN of GET Lambda from lambda module"
  type        = string
}

variable "post_contact_function_name" {
  description = "Function name of POST Lambda"
  type        = string
}

variable "get_messages_function_name" {
  description = "Function name of GET Lambda"
  type        = string
}

variable "log_retention_days" {
  type    = number
  default = 7
}
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "table_name" {
  description = "DynamoDB table name from dynamodb module"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN from iam module"
  type        = string
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "lambda_source_path" {
  description = "Path to lambda folder"
  type        = string
}
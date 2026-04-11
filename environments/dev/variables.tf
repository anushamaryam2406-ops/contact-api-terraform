# ============================================================================
# FILE: variables.tf
# Input variables for Contact API infrastructure
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name (used in resource naming)"
  type        = string
  default     = "contact-messages"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "Billing mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "enable_pitr" {
  description = "Enable Point-in-Time Recovery for backups"
  type        = bool
  default     = false  # Set to true for production
}

variable "enable_ttl" {
  description = "Enable TTL for automatic message expiration"
  type        = bool
  default     = false  # Set to true if you want auto-deletion
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period (days)"
  type        = number
  default     = 7
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 180, 365], var.log_retention_days)
    error_message = "Invalid log retention period."
  }
}

# ============================================================================
# OPTIONAL: Provisioned Capacity Settings (only if billing_mode = PROVISIONED)
# ============================================================================

variable "read_capacity" {
  description = "Read capacity units (only used if PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only used if PROVISIONED mode)"
  type        = number
  default     = 5
}

# ============================================================================
# TAGS
# ============================================================================

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}
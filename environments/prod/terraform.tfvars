# ============================================================================
# FILE: terraform.tfvars
# Your production configuration values
# ============================================================================

# AWS Configuration
aws_region = "ap-south-1"  # Mumbai (closest to Pakistan)

# Project Settings
project_name = "contact-messages"
environment  = "prod"

# DynamoDB Settings
billing_mode = "PAY_PER_REQUEST"  # On-Demand (recommended for development)

# Backup & Recovery
enable_pitr = true  # Production backup best practice
enable_ttl  = false  # Set to true if you want auto-deletion of old messages

# Logging
log_retention_days = 30  # Keep logs longer in prod

# Optional: Additional Tags
additional_tags = {
  Owner       = "Anusha"
  CostCenter  = "Learning"
  Repository  = "github.com/anusha/contact-api"
}

# Production-specific tuning
# billing_mode = "PROVISIONED"  # Optional: if traffic is predictable
# read_capacity = 10
# write_capacity = 5

# ============================================================================
# FILE: terraform.tfvars
# Your specific configuration values
# ============================================================================

# AWS Configuration
aws_region = "ap-south-1"  # Mumbai (closest to Pakistan)

# Project Settings
project_name = "contact-messages"
environment  = "dev"  # Change to 'prod' for production

# DynamoDB Settings
billing_mode = "PAY_PER_REQUEST"  # On-Demand (recommended for development)

# Backup & Recovery
enable_pitr = false  # Set to true for production (enables backups)
enable_ttl  = false  # Set to true if you want auto-deletion of old messages

# Logging
log_retention_days = 7  # Keep logs for 7 days (save cost in dev)

# Optional: Additional Tags
additional_tags = {
  Owner       = "Anusha"
  CostCenter  = "Learning"
  Repository  = "github.com/anusha/contact-api"
}
alert_email = "anushamaryam2406@gmail.com"
# ============================================================================
# PRODUCTION SETTINGS (uncomment when deploying to production)
# ============================================================================

# environment  = "prod"
# enable_pitr  = true
# log_retention_days = 30
# billing_mode = "PROVISIONED"  # Optional: if traffic is predictable
# read_capacity = 10
# write_capacity = 5

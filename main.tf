# PROJECT: Contact API - Complete Infrastructure
# Phase 3 - Serverless Contact/Feedback Backend

# ============================================================================
# FILE: main.tf
# Complete DynamoDB table with GSI for Contact API
# ============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.37"
    }
  }
  
  backend "s3" {
    bucket         = "anusha-tf-state-2024"
    key            = "contact-api/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "ContactAPI"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# ============================================================================
# CONTACT MESSAGES TABLE
# ============================================================================

resource "aws_dynamodb_table" "contact_messages" {
  name         = "${var.project_name}-${var.environment}"
  billing_mode = var.billing_mode
  
  # Primary Key
  hash_key  = "email"
  range_key = "timestamp"
  
  # Define key attributes
  attribute {
    name = "email"
    type = "S"
  }
  
  attribute {
    name = "timestamp"
    type = "S"
  }
  
  attribute {
    name = "status"
    type = "S"
  }
  
  # Global Secondary Index for status-based queries
  global_secondary_index {
    name = "status-timestamp-index"
    
    key_schema {
      attribute_name = "status"
      key_type       = "HASH"
    }
    
    key_schema {
      attribute_name = "timestamp"
      key_type       = "RANGE"
    }
    
    projection_type = "ALL"
  }
  
  # Enable Point-in-Time Recovery (production best practice)
  point_in_time_recovery {
    enabled = var.enable_pitr
  }
  
  # Enable TTL for auto-deletion of old messages (optional)
  ttl {
    attribute_name = "expiry_time"
    enabled        = var.enable_ttl
  }
  
  # Server-side encryption
  server_side_encryption {
    enabled = true
  }
  
  # Tags
  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Description = "Contact form messages with status tracking"
  }
}

# ============================================================================
# IAM ROLE FOR LAMBDA (Future use)
# ============================================================================

resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-lambda-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name = "${var.project_name}-lambda-role"
  }
}

# Lambda basic execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB access policy for Lambda
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_execution.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.contact_messages.arn,
          "${aws_dynamodb_table.contact_messages.arn}/index/*"
        ]
      }
    ]
  })
}

# ============================================================================
# CLOUDWATCH LOG GROUP (For Lambda logs)
# ============================================================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name = "${var.project_name}-logs"
  }
}

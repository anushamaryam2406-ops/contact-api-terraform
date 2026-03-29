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


# ============================================================================
# LAMBDA FUNCTION 1: POST /contact
# ============================================================================

# Package Lambda code Terraform: "I'll zip it for you!"
data "archive_file" "post_contact" {
  type        = "zip"
  source_file = "${path.module}/lambda_post_contact.py"
  output_path = "${path.module}/lambda_post_contact.zip"
}

resource "aws_lambda_function" "post_contact" {
  filename         = data.archive_file.post_contact.output_path
  function_name    = "${var.project_name}-post-${var.environment}"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "lambda_post_contact.lambda_handler"
  source_code_hash = data.archive_file.post_contact.output_base64sha256
  runtime         = "python3.11"
  timeout         = 10
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contact_messages.name
    }
  }
  
  tags = {
    Name = "${var.project_name}-post"
  }
}

# CloudWatch Log Group for POST Lambda
resource "aws_cloudwatch_log_group" "post_contact" {
  name              = "/aws/lambda/${aws_lambda_function.post_contact.function_name}"
  retention_in_days = var.log_retention_days
}

# ============================================================================
# LAMBDA FUNCTION 2: GET /messages
# ============================================================================

data "archive_file" "get_messages" {
  type        = "zip"
  source_file = "${path.module}/lambda_get_messages.py"
  output_path = "${path.module}/lambda_get_messages.zip"
}

resource "aws_lambda_function" "get_messages" {
  filename         = data.archive_file.get_messages.output_path
  function_name    = "${var.project_name}-get-${var.environment}"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "lambda_get_messages.lambda_handler"
  source_code_hash = data.archive_file.get_messages.output_base64sha256
  runtime         = "python3.11"
  timeout         = 10
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contact_messages.name
    }
  }
  
  tags = {
    Name = "${var.project_name}-get"
  }
}

resource "aws_cloudwatch_log_group" "get_messages" {
  name              = "/aws/lambda/${aws_lambda_function.get_messages.function_name}"
  retention_in_days = var.log_retention_days
}

# ============================================================================
# API GATEWAY (HTTP API) - POST /contact → Lambda POST function
#- GET /messages → Lambda GET function
# ============================================================================

resource "aws_apigatewayv2_api" "contact_api" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
  
  tags = {
    Name = "${var.project_name}-api"
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.contact_api.id
  name        = var.environment
  auto_deploy = true
  
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }
  
  tags = {
    Name = "${var.project_name}-stage"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
}

# ============================================================================
# API ROUTES & INTEGRATIONS
# ============================================================================

# POST /contact Integration
resource "aws_apigatewayv2_integration" "post_contact" {
  api_id           = aws_apigatewayv2_api.contact_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.post_contact.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_contact" {
  api_id    = aws_apigatewayv2_api.contact_api.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.post_contact.id}"
}

# GET /messages Integration
resource "aws_apigatewayv2_integration" "get_messages" {
  api_id           = aws_apigatewayv2_api.contact_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_messages.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_messages" {
  api_id    = aws_apigatewayv2_api.contact_api.id
  route_key = "GET /messages"
  target    = "integrations/${aws_apigatewayv2_integration.get_messages.id}"
}

# ============================================================================
# LAMBDA PERMISSIONS (Allow API Gateway to invoke)
# ============================================================================

resource "aws_lambda_permission" "post_contact" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_contact.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.contact_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_messages" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_messages.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.contact_api.execution_arn}/*/*"
}

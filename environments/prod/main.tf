# ============================================================================
# FILE: environments/dev/main.tf
# Phase 6 - Refactored with Terraform Modules
# Environment: DEV
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.37"
    }
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
# IAM ROLE (stays here  shared across modules)
# ============================================================================
resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      Resource = [
        module.dynamodb.table_arn,
        "${module.dynamodb.table_arn}/index/*"
      ]
    }]
  })
}

# ============================================================================
# MODULE 1: DYNAMODB
# ============================================================================
module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
  billing_mode = var.billing_mode
  enable_pitr  = var.enable_pitr
  enable_ttl   = var.enable_ttl
}

# ============================================================================
# MODULE 2: LAMBDA
# ============================================================================
module "lambda" {
  source = "../../modules/lambda"

  project_name       = var.project_name
  environment        = var.environment
  table_name         = module.dynamodb.table_name  #  from dynamodb module!
  lambda_role_arn    = aws_iam_role.lambda_execution.arn
  log_retention_days = var.log_retention_days
  lambda_source_path = "${path.module}/../../lambda"
}

# ============================================================================
# MODULE 3: API GATEWAY
# ============================================================================
module "api_gateway" {
  source = "../../modules/api_gateway"

  project_name               = var.project_name
  environment                = var.environment
  post_contact_invoke_arn    = module.lambda.post_contact_arn    #  from lambda module!
  get_messages_invoke_arn    = module.lambda.get_messages_arn    #  from lambda module!
  post_contact_function_name = module.lambda.post_contact_name   #  from lambda module!
  get_messages_function_name = module.lambda.get_messages_name   #  from lambda module!
  log_retention_days         = var.log_retention_days
}

# ============================================================================
# MODULE 4: MONITORING
# ============================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  project_name               = var.project_name
  environment                = var.environment
  post_contact_function_name = module.lambda.post_contact_name  #  from lambda module!
  get_messages_function_name = module.lambda.get_messages_name  #  from lambda module!
  alert_email                = var.alert_email
  error_threshold            = 1      # dev = relaxed
  alarm_period               = 60   # dev = 5 minutes
  duration_threshold         = 3000   # dev = 5 seconds
}
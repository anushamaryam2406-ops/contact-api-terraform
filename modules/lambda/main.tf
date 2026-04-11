# ============================================================================
# POST Lambda
# ============================================================================
data "archive_file" "post_contact" {
  type        = "zip"
  source_file = "${var.lambda_source_path}/post_contact.py"
  output_path = "${path.module}/lambda_post_contact.zip"
}

resource "aws_lambda_function" "post_contact" {
  filename         = data.archive_file.post_contact.output_path
  function_name    = "${var.project_name}-post-${var.environment}"
  role             = var.lambda_role_arn
  handler          = "post_contact.lambda_handler"
  source_code_hash = data.archive_file.post_contact.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  tags = {
    Name = "${var.project_name}-post"
  }
}

resource "aws_cloudwatch_log_group" "post_contact" {
  name              = "/aws/lambda/${aws_lambda_function.post_contact.function_name}"
  retention_in_days = var.log_retention_days
}

# ============================================================================
# GET Lambda
# ============================================================================
data "archive_file" "get_messages" {
  type        = "zip"
  source_file = "${var.lambda_source_path}/get_messages.py"
  output_path = "${path.module}/lambda_get_messages.zip"
}

resource "aws_lambda_function" "get_messages" {
  filename         = data.archive_file.get_messages.output_path
  function_name    = "${var.project_name}-get-${var.environment}"
  role             = var.lambda_role_arn
  handler          = "get_messages.lambda_handler"
  source_code_hash = data.archive_file.get_messages.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = var.table_name
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
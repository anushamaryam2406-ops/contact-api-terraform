# ============================================================================
# FILE: outputs.tf
# Output values after deployment
# ============================================================================

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.contact_messages.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.contact_messages.arn
}

output "gsi_name" {
  description = "Name of the Global Secondary Index"
  value       = "status-timestamp-index"
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.name
}

output "log_group_name" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

# ============================================================================
# CONNECTION INFO (For testing)
# ============================================================================

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# ============================================================================
# QUERY EXAMPLES (For developers)
# ============================================================================

output "query_examples" {
  description = "Example queries for this table"
  value = {
    by_email = "aws dynamodb query --table-name ${aws_dynamodb_table.contact_messages.name} --key-condition-expression 'email = :email' --expression-attribute-values '{\":email\":{\"S\":\"user@example.com\"}}'"
    
    by_status = "aws dynamodb query --table-name ${aws_dynamodb_table.contact_messages.name} --index-name status-timestamp-index --key-condition-expression '#status = :status' --expression-attribute-names '{\"#status\":\"status\"}' --expression-attribute-values '{\":status\":{\"S\":\"new\"}}'"
  }
}


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

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "post_contact_url" {
  description = "POST /contact endpoint"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/contact"
}

output "get_messages_url" {
  description = "GET /messages endpoint"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/messages"
}

output "lambda_post_function" {
  description = "POST Lambda function name"
  value       = aws_lambda_function.post_contact.function_name
}

output "lambda_get_function" {
  description = "GET Lambda function name"
  value       = aws_lambda_function.get_messages.function_name
}

# ============================================================================
# TESTING COMMANDS
# ============================================================================

output "test_commands" {
  description = "Commands to test the API"
  value = <<-EOT
  
  ═══════════════════════════════════════════════════════════════
  TEST YOUR API
  ═══════════════════════════════════════════════════════════════
  
  1. SUBMIT CONTACT FORM (POST):
  
  curl -X POST ${aws_apigatewayv2_stage.default.invoke_url}/contact \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Anusha",
      "email": "anusha@example.com",
      "subject": "Test Message",
      "message": "Testing my Contact API!"
    }'
  
  2. GET ALL NEW MESSAGES:
  
  curl "${aws_apigatewayv2_stage.default.invoke_url}/messages?status=new"
  
  3. GET MESSAGES BY EMAIL:
  
  curl "${aws_apigatewayv2_stage.default.invoke_url}/messages?email=anusha@example.com"
  
  4. GET ALL MESSAGES:
  
  curl "${aws_apigatewayv2_stage.default.invoke_url}/messages"
  
  ═══════════════════════════════════════════════════════════════
  EOT
}

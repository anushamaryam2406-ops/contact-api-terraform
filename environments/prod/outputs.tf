output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.api_gateway.api_endpoint
}

output "table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}
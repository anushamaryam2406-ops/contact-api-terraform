output "post_contact_arn" {
  value = aws_lambda_function.post_contact.invoke_arn
}

output "post_contact_name" {
  value = aws_lambda_function.post_contact.function_name
}

output "get_messages_arn" {
  value = aws_lambda_function.get_messages.invoke_arn
}

output "get_messages_name" {
  value = aws_lambda_function.get_messages.function_name
}
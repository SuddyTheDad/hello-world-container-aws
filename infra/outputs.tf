output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "app_runner_service_url" {
  description = "URL of the App Runner service"
  value       = "https://${aws_apprunner_service.main.service_url}"
}

output "app_runner_service_arn" {
  description = "ARN of the App Runner service"
  value       = aws_apprunner_service.main.arn
}

output "func_ecr_repository_url" {
  description = "ECR repository URL for Lambda functions"
  value       = aws_ecr_repository.func.repository_url
}

output "api_gateway_url" {
  description = "URL of the API Gateway (Lambda HTTP trigger)"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/hello"
}

output "lambda_http_function_name" {
  description = "Name of the HTTP-triggered Lambda function"
  value       = aws_lambda_function.http.function_name
}

output "lambda_scheduled_function_name" {
  description = "Name of the scheduled Lambda function"
  value       = aws_lambda_function.scheduled.function_name
}

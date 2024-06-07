
output "api_gateway_url" {
  description = "The URL to call the provisioned API"
  value       = aws_api_gateway_stage.default_stage.invoke_url
}


terraform {
  backend "s3" {
    bucket         = "hansraptor-terraform-state-bucket"
    key            = "poc-lambda-web-server-vs-microservice/monolith.tfstate"
    region         = "af-south-1"
    dynamodb_table = "hansraptor-terraform-lock-table"
  }
}

locals {
  api_name                                    = "api-monolith"
  lambda_name                                 = "monolith-web-server"
  allow_write_log_group_stream_event_role_arn = "arn:aws:iam::767398121047:role/allow-write-log-group-stream-event-role"
  function_source_location                    = "../../code/monolith"
}

data "archive_file" "function_zip" {
  type       = "zip"
  source_dir = local.function_source_location
  excludes = [
    ".gitignore",
    "monolith.zip",
    "package.json",
    "package-lock.json"
  ]
  output_file_mode = "0666"
  output_path      = "${local.function_source_location}/monolith.zip"
}

resource "aws_lambda_function" "webserver_lambda" {
  function_name    = local.lambda_name
  role             = local.allow_write_log_group_stream_event_role_arn
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  filename         = data.archive_file.function_zip.output_path
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  depends_on = [
    data.archive_file.function_zip
  ]
}

resource "aws_api_gateway_rest_api" "monolith_api" {
  name = local.api_name
  description = "API wrapping a single endpoint integrating with a lambda-based web server to route and handle requests"
}

resource "aws_api_gateway_resource" "greedy_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.monolith_api.id
  parent_id = aws_api_gateway_rest_api.monolith_api.root_resource_id
  path_part = "{proxy+}"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api
  ]
}

resource "aws_api_gateway_method" "proxy_any_method" {
  rest_api_id = aws_api_gateway_rest_api.monolith_api.id
  resource_id = aws_api_gateway_resource.greedy_proxy_resource.id
  authorization = "NONE"
  http_method = "ANY"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_resource.greedy_proxy_resource
  ]
}

resource "aws_api_gateway_integration" "proxy_any_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.monolith_api.id
  resource_id             = aws_api_gateway_resource.greedy_proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_any_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.webserver_lambda.invoke_arn

  depends_on = [
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_resource.greedy_proxy_resource,
    aws_api_gateway_method.proxy_any_method,
    aws_lambda_function.webserver_lambda
  ]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayLambdaProxyIntegration"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webserver_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.monolith_api.execution_arn}/*/*/*"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_method.proxy_any_method
  ]
}

resource "aws_api_gateway_deployment" "default_deployment" {
  rest_api_id = aws_api_gateway_rest_api.monolith_api.id

  # stage_name = "" # Not recommended by Terraform docs

  depends_on = [
    aws_lambda_function.webserver_lambda,
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_method.proxy_any_method,
    aws_api_gateway_integration.proxy_any_lambda_integration,
    aws_lambda_permission.apigw_lambda
  ]
}

resource "aws_api_gateway_stage" "default_stage" {
  stage_name = "default"
  rest_api_id = aws_api_gateway_rest_api.monolith_api.id
  deployment_id = aws_api_gateway_deployment.default_deployment.id

  depends_on = [
    aws_api_gateway_deployment.default_deployment
  ]
}

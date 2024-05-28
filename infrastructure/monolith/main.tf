
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
  lambda_arn                                  = "arn:aws:lambda:af-south-1:767398121047:function:test-api-gateway-invoke"
  lambda_name                                 = "test-api-gateway-invoke"
  allow_write_log_group_stream_event_role_arn = "arn:aws:iam::767398121047:role/allow-write-log-group-stream-event-role"
  function_source_location                    = "../../code/monolith"
}

resource "aws_api_gateway_rest_api" "monolith_api" {
  name = local.api_name
}

resource "aws_api_gateway_method" "root_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.monolith_api.id
  resource_id   = aws_api_gateway_rest_api.monolith_api.root_resource_id
  authorization = "NONE"
  http_method   = "POST"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api
  ]
}

data "archive_file" "function_zip" {
  type       = "zip"
  source_dir = local.function_source_location
  excludes = [
    ".gitignore",
    "function.zip"
  ]
  output_file_mode = "0666"
  output_path      = "${local.function_source_location}/monolith.zip"
}

resource "aws_lambda_function" "webserver_lambda" {
  function_name    = local.lambda_name
  role             = local.allow_write_log_group_stream_event_role_arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.function_zip.output_path
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  depends_on = [
    data.archive_file.function_zip
  ]
}

resource "aws_api_gateway_integration" "root_post_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.monolith_api.id
  resource_id             = aws_api_gateway_rest_api.monolith_api.root_resource_id
  http_method             = aws_api_gateway_method.root_post_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.webserver_lambda.invoke_arn

  depends_on = [
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_method.root_post_method,
    data.aws_lambda_function.webserver_lambda
  ]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.monolith_api.execution_arn}/*/${aws_api_gateway_method.root_post_method.http_method}/"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_method.root_post_method
  ]
}

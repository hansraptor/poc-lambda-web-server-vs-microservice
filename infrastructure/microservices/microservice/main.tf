
locals {
  package_name = "function"
}

data "external" "lambda_build" {
  working_dir = var.function_source_location
  program = ["bash", "-c", <<BUILD
(npm ci && npm test && npm run build) >&2 && echo "{\"output-folder\":\"dist\"}"
BUILD
  ]
  # query = {
  # 	...
  # }
}

data "archive_file" "function_zip" {
  type       = "zip"
  source_dir = "${var.function_source_location}/dist"
  #   excludes = [
  #     ".gitignore",
  #     "${local.package_name}.zip",
  #     "package.json",
  #     "package-lock.json"
  #   ]
  output_file_mode = "0666"
  output_path      = "${var.function_source_location}/${local.package_name}.zip"

  depends_on = [
    data.external.lambda_build
  ]
}

resource "aws_lambda_function" "microservice_lambda" {
  function_name    = var.lambda_name
  layers           = var.layer_arn
  role             = var.execution_role
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.function_zip.output_path
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  depends_on = [
    data.archive_file.function_zip
  ]
}

resource "aws_api_gateway_method" "resource_method" {
  rest_api_id   = var.api_id
  resource_id   = var.resource_id
  authorization = "NONE"
  http_method   = var.http_method

  depends_on = [
  ]
}

resource "aws_api_gateway_integration" "method_integration" {
  rest_api_id             = var.api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.resource_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.microservice_lambda.invoke_arn

  depends_on = [
    aws_api_gateway_method.resource_method,
    aws_lambda_function.microservice_lambda
  ]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayLambdaProxyIntegration"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.microservice_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/${var.http_method}${var.route_path}"

  depends_on = [
    aws_api_gateway_method.resource_method
  ]
}

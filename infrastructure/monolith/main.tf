
terraform {
  backend "s3" {
    bucket         = "hansraptor-terraform-state-bucket"
    key            = "poc-lambda-web-server-vs-microservice/monolith.tfstate"
    region         = "af-south-1"
    dynamodb_table = "hansraptor-terraform-lock-table"
  }
}

locals {
  api_name = "api-monolith"
  lambda_arn = "arn:aws:lambda:af-south-1:767398121047:function:test-api-gateway-invoke"
  lambda_name = "test-api-gateway-invoke"
}

resource "aws_api_gateway_rest_api" "monolith_api" {
  name = local.api_name
}

resource "aws_api_gateway_method" "root_post_method" {
  rest_api_id = aws_api_gateway_rest_api.monolith_api.id
  resource_id = aws_api_gateway_rest_api.monolith_api.root_resource_id
  authorization = "NONE"
  http_method = "POST"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api
  ]
}

data "aws_lambda_function" "target_lambda" {
  function_name = local.lambda_name
}

resource "aws_api_gateway_integration" "root_post_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.monolith_api.id
  resource_id = aws_api_gateway_rest_api.monolith_api.root_resource_id
  http_method = aws_api_gateway_method.root_post_method.http_method
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = data.aws_lambda_function.target_lambda.invoke_arn

  depends_on = [
    aws_api_gateway_rest_api.monolith_api,
    aws_api_gateway_method.root_post_method,
    data.aws_lambda_function.target_lambda
  ]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.monolith_api.execution_arn}/*/${aws_api_gateway_method.root_post_method.http_method}/"

  depends_on = [
    aws_api_gateway_rest_api.monolith_api
  ]
}

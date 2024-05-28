
terraform {
  backend "s3" {
    bucket         = "hansraptor-terraform-state-bucket"
    key            = "poc-lambda-web-server-vs-microservice/microservices.tfstate"
    region         = "af-south-1"
    dynamodb_table = "hansraptor-terraform-lock-table"
  }
}

locals {
  api_name                                    = "api-microservices"
  allow_write_log_group_stream_event_role_arn = "arn:aws:iam::767398121047:role/allow-write-log-group-stream-event-role"
  function_source_base_path                    = "../../code/microservices"
}

resource "aws_api_gateway_rest_api" "microservice_api" {
  name = local.api_name
  description = "API wrapping a single endpoint integrating with a lambda-based web server to route and handle requests"
}

// TODO: Declare API resources here and pass references to microservice 
// modules appropriately to group & organise the API structure
resource "aws_api_gateway_resource" "user_service_resource" {
  rest_api_id = aws_api_gateway_rest_api.microservice_api.id
  parent_id = aws_api_gateway_rest_api.microservice_api.root_resource_id
  path_part = "user-service"

  depends_on = [
    aws_api_gateway_rest_api.microservice_api
  ]
}

// TODO: Declare microservice modules here!
module "emli_lms_getusers" {
  source = "./microservice"

    lambda_name = "user-service-get-users"
    function_source_location = "../../code/microservices/get-users"
    execution_role = local.allow_write_log_group_stream_event_role_arn
    api_id = aws_api_gateway_rest_api.microservice_api.id
    api_execution_arn = aws_api_gateway_rest_api.microservice_api.execution_arn
    resource_id = aws_api_gateway_resource.user_service_resource.id
    http_method = "GET"
}

resource "aws_api_gateway_deployment" "default_deployment" {
  rest_api_id = aws_api_gateway_rest_api.microservice_api.id

  # stage_name = "" # Not recommended by Terraform docs

  depends_on = [
    module.emli_lms_getusers,
    aws_api_gateway_rest_api.microservice_api
  ]
}

resource "aws_api_gateway_stage" "default_stage" {
  stage_name = "default"
  rest_api_id = aws_api_gateway_rest_api.microservice_api.id
  deployment_id = aws_api_gateway_deployment.default_deployment.id

  depends_on = [
    aws_api_gateway_deployment.default_deployment
  ]
}

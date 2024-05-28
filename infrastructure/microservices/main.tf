
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
  function_source_base_path                   = "../../code/microservices"
}

resource "aws_api_gateway_rest_api" "microservice_api" {
  name        = local.api_name
  description = "API wrapping a single endpoint integrating with a lambda-based web server to route and handle requests"
}

// TODO: Declare API resources here and pass references to microservice 
// modules appropriately to group & organise the API structure
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.microservice_api.id
  parent_id   = aws_api_gateway_rest_api.microservice_api.root_resource_id
  path_part   = "users"

  depends_on = [
    aws_api_gateway_rest_api.microservice_api
  ]
}

resource "aws_api_gateway_resource" "users_byid_resource" {
  rest_api_id = aws_api_gateway_rest_api.microservice_api.id
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "{id}"

  depends_on = [
    aws_api_gateway_resource.users_resource
  ]
}

// TODO: Declare microservice modules here!
module "emli_lms_listusers" {
  source = "./microservice"

  lambda_name              = "user-service-list-users"
  function_source_location = "../../code/microservices/list-users"
  execution_role           = local.allow_write_log_group_stream_event_role_arn
  api_id                   = aws_api_gateway_rest_api.microservice_api.id
  api_execution_arn        = aws_api_gateway_rest_api.microservice_api.execution_arn
  resource_id              = aws_api_gateway_resource.users_resource.id
  route_path            = aws_api_gateway_resource.users_resource.path
  http_method              = "GET"

  depends_on = [
    aws_api_gateway_resource.users_resource
  ]
}

module "emli_lms_fetchuser" {
  source = "./microservice"

  lambda_name              = "user-service-fetch-user"
  function_source_location = "../../code/microservices/fetch-user"
  execution_role           = local.allow_write_log_group_stream_event_role_arn
  api_id                   = aws_api_gateway_rest_api.microservice_api.id
  api_execution_arn        = aws_api_gateway_rest_api.microservice_api.execution_arn
  resource_id              = aws_api_gateway_resource.users_byid_resource.id
  route_path            = aws_api_gateway_resource.users_byid_resource.path
  http_method              = "GET"

  depends_on = [
    aws_api_gateway_resource.users_byid_resource
  ]
}

module "emli_lms_createuser" {
  source = "./microservice"

  lambda_name              = "user-service-create-user"
  function_source_location = "../../code/microservices/create-user"
  execution_role           = local.allow_write_log_group_stream_event_role_arn
  api_id                   = aws_api_gateway_rest_api.microservice_api.id
  api_execution_arn        = aws_api_gateway_rest_api.microservice_api.execution_arn
  resource_id              = aws_api_gateway_resource.users_byid_resource.id
  route_path            = aws_api_gateway_resource.users_byid_resource.path
  http_method              = "POST"

  depends_on = [
    aws_api_gateway_resource.users_byid_resource
  ]
}

module "emli_lms_updateuser" {
  source = "./microservice"

  lambda_name              = "user-service-update-user"
  function_source_location = "../../code/microservices/update-user"
  execution_role           = local.allow_write_log_group_stream_event_role_arn
  api_id                   = aws_api_gateway_rest_api.microservice_api.id
  api_execution_arn        = aws_api_gateway_rest_api.microservice_api.execution_arn
  resource_id              = aws_api_gateway_resource.users_byid_resource.id
  route_path            = aws_api_gateway_resource.users_byid_resource.path
  http_method              = "PUT"

  depends_on = [
    aws_api_gateway_resource.users_byid_resource
  ]
}

module "emli_lms_deactivateuser" {
  source = "./microservice"

  lambda_name              = "user-service-deactivate-user"
  function_source_location = "../../code/microservices/deactivate-user"
  execution_role           = local.allow_write_log_group_stream_event_role_arn
  api_id                   = aws_api_gateway_rest_api.microservice_api.id
  api_execution_arn        = aws_api_gateway_rest_api.microservice_api.execution_arn
  resource_id              = aws_api_gateway_resource.users_byid_resource.id
  route_path            = aws_api_gateway_resource.users_byid_resource.path
  http_method              = "DELETE"

  depends_on = [
    aws_api_gateway_resource.users_byid_resource
  ]
}

resource "aws_api_gateway_deployment" "default_deployment" {
  rest_api_id = aws_api_gateway_rest_api.microservice_api.id

  # stage_name = "" # Not recommended by Terraform docs

  depends_on = [
    module.emli_lms_listusers,
    module.emli_lms_fetchuser,
    module.emli_lms_createuser,
    module.emli_lms_updateuser,
    module.emli_lms_deactivateuser,
    aws_api_gateway_rest_api.microservice_api
  ]
}

resource "aws_api_gateway_stage" "default_stage" {
  stage_name    = "default"
  rest_api_id   = aws_api_gateway_rest_api.microservice_api.id
  deployment_id = aws_api_gateway_deployment.default_deployment.id

  depends_on = [
    aws_api_gateway_deployment.default_deployment
  ]
}

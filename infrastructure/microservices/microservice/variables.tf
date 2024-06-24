
variable "lambda_name" {
  description = "Name of the Lambda function that will be created and used for this endpoint's integration"
  type        = string
}

variable "function_source_location" {
  description = "Relative location where the function's source code is located"
  type        = string
}

variable "layer_arn" {
  description = "Optional ARN of a lambda layer to associate with this lambda"
  type        = set(string)
  default     = []
}

variable "execution_role" {
  description = "The role ARN that will be assigned to the Lambda for execution"
  type        = string
}

variable "api_id" {
  description = "The API Gateway ID where the resource that contains this Lambda integration is located"
  type        = string
}

variable "api_execution_arn" {
  description = "The execution ARN of the API"
  type        = string
}

variable "resource_id" {
  description = "The API Gateway recource ID that will contain this Lambda integration"
  type        = string
}

variable "route_path" {
  description = "The path of the API resource where the method will be defined"
  type        = string
}

variable "http_method" {
  description = "The HTTP method that will integration with the Lambda function"
  type        = string
}


terraform {
  backend "s3" {
    bucket         = "hansraptor-terraform-state-bucket"
    key            = "poc-lambda-web-server-vs-microservice/microservices.tfstate"
    region         = "af-south-1"
    dynamodb_table = "hansraptor-terraform-lock-table"
  }
}

locals {
  
}

resource "aws_api_gateway_rest_api" "api_monolith" {
  name = "api-microservices"
}

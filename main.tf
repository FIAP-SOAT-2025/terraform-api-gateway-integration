terraform {
  backend "s3" {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "api-gateway-integration/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

# data "terraform_remote_state" "api" {
#   backend = "s3"
#   config = {
#     bucket = "terraform-state-tc4-lanchonete"
#     key    = "api/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

data "terraform_remote_state" "item" {
  backend = "s3"
  config = {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "item/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


# resource "aws_apigatewayv2_authorizer" "cognito_jwt_authorizer" {
#   api_id           = data.terraform_remote_state.infra.outputs.api_gateway_id
#   authorizer_type  = "JWT"
#   name             = "CognitoJWTAuthorizer"
#   identity_sources = ["$request.header.Authorization"]

#   jwt_configuration {
#     audience = [aws_cognito_user_pool_client.api_client.id]
#     issuer   = "https://${aws_cognito_user_pool.customer_pool.endpoint}"
#   }
# }

# resource "aws_apigatewayv2_integration" "create_customer_lambda_integration" {
#   api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
#   integration_type   = "AWS_PROXY"
#   integration_uri    = aws_lambda_function.create_customer.invoke_arn
# }

# resource "aws_apigatewayv2_integration" "get_customer_lambda_integration" {
#   api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
#   integration_type   = "AWS_PROXY"
#   integration_uri    = aws_lambda_function.get_customer_by_cpf.invoke_arn
# }

# resource "aws_apigatewayv2_route" "create_customer_route" {
#   api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
#   route_key = "POST /customer"
#   target    = "integrations/${aws_apigatewayv2_integration.create_customer_lambda_integration.id}"
# }

# resource "aws_apigatewayv2_route" "get_customer_route" {
#   api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
#   route_key = "GET /customer/{cpf}"
#   target    = "integrations/${aws_apigatewayv2_integration.get_customer_lambda_integration.id}"
# }


resource "aws_apigatewayv2_integration" "lanchonete_integration" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.terraform_remote_state.item.outputs.lanchonete_api_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = data.terraform_remote_state.infra.outputs.vpc_link_id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration.id}"

  # authorization_type = "JWT"
  # authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}


resource "aws_apigatewayv2_route" "root_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration.id}"

  # authorization_type = "JWT"
  # authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}


resource "aws_apigatewayv2_route" "swagger_ui_root" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "GET /api"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration.id}"
}

resource "aws_apigatewayv2_route" "swagger_ui_assets" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "GET /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration.id}"
}
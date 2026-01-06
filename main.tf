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

data "terraform_remote_state" "customer" {
  backend = "s3"
  config = {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "customer/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "item" {
  backend = "s3"
  config = {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "item/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "order" {
  backend = "s3"
  config = {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "order/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "payments" {
  backend = "s3"
  config = {
    bucket = "terraform-state-tc4-lanchonete"
    key    = "payments/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_apigatewayv2_authorizer" "cognito_jwt_authorizer" {
  api_id           = data.terraform_remote_state.infra.outputs.api_gateway_id
  authorizer_type  = "JWT"
  name             = "CognitoJWTAuthorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.api_client.id]
    issuer   = "https://${aws_cognito_user_pool.customer_pool.endpoint}"
  }
}

resource "aws_apigatewayv2_integration" "create_customer_lambda_integration" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.create_customer.invoke_arn
}

resource "aws_apigatewayv2_integration" "get_customer_lambda_integration" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.get_customer_by_cpf.invoke_arn
}

resource "aws_apigatewayv2_route" "create_customer_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "POST /customer"
  target    = "integrations/${aws_apigatewayv2_integration.create_customer_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "get_customer_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "GET /customer/{cpf}"
  target    = "integrations/${aws_apigatewayv2_integration.get_customer_lambda_integration.id}"
}


resource "aws_apigatewayv2_integration" "lanchonete_integration_item" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.terraform_remote_state.item.outputs.lanchonete_api_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = data.terraform_remote_state.infra.outputs.vpc_link_id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "lanchonete_integration_order" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.terraform_remote_state.order.outputs.lanchonete_api_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = data.terraform_remote_state.infra.outputs.vpc_link_id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "lanchonete_integration_payments" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.terraform_remote_state.payments.outputs.lanchonete_api_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = data.terraform_remote_state.infra.outputs.vpc_link_id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "lanchonete_integration_customer" {
  api_id             = data.terraform_remote_state.infra.outputs.api_gateway_id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.terraform_remote_state.customer.outputs.lanchonete_api_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = data.terraform_remote_state.infra.outputs.vpc_link_id
  integration_method = "ANY"
}

# resource "aws_apigatewayv2_route" "customer_proxy_route" {
#   api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
#   route_key = "GET /customer/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration_customer.id}"
  
#   authorization_type = "JWT"
#   authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
# }

resource "aws_apigatewayv2_route" "item_proxy_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "GET /item/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration_item.id}"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}

resource "aws_apigatewayv2_route" "order_proxy_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "GET /order/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration_order.id}"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}

resource "aws_apigatewayv2_route" "payments_proxy_route" {
  api_id    = data.terraform_remote_state.infra.outputs.api_gateway_id
  route_key = "GET /payment/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lanchonete_integration_payments.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt_authorizer.id
}

# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}
# data "aws_partition" "current" {}

# # data "archive_file" "create_customer_zip" {
# #   type        = "zip"
# #   source_dir  = "${path.module}/lambdas/create-customer"
# #   output_path = "${path.module}/lambdas/create-customer.zip"
# # }

# # data "archive_file" "get_customer_zip" {
# #   type        = "zip"
# #   source_dir  = "${path.module}/lambdas/get-customer"
# #   output_path = "${path.module}/lambdas/get-customer.zip"
# # }

# resource "aws_lambda_function" "create_customer" {
#   function_name    = "CreateCustomer"
#   s3_bucket     = "lambda-code-tc3-g38"
#   s3_key        = "create-customer.zip"
#   handler = "index.handler"
#   runtime = "nodejs18.x"
#   role    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

#   timeout     = 15
#   memory_size = 256

#   environment {
#     variables = {
#       COGNITO_USER_POOL_ID = aws_cognito_user_pool.customer_pool.id
#       COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.api_client.id
#       API_ENDPOINT = data.terraform_remote_state.infra.outputs.api_gateway_url
#     }
#   }
# }

# resource "aws_lambda_function" "get_customer_by_cpf" {
#   function_name    = "GetCustomerByCPF"
#   s3_bucket     = "lambda-code-tc3-g38"
#   s3_key        = "get-customer.zip"

#   handler = "index.handler"
#   runtime = "nodejs18.x"
#   role    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

#   timeout     = 15
#   memory_size = 256

#   environment {
#     variables = {
#       COGNITO_USER_POOL_ID = aws_cognito_user_pool.customer_pool.id
#       COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.api_client.id
#     }
#   }
# }


# resource "aws_lambda_permission" "api_gw_create_customer" {
#   statement_id  = "AllowAPIGatewayInvokeCreateCustomer"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.create_customer.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "arn:${data.aws_partition.current.partition}:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${data.terraform_remote_state.infra.outputs.api_gateway_id}/*/*"
# }

# resource "aws_lambda_permission" "api_gw_get_customer" {
#   statement_id  = "AllowAPIGatewayInvokeGetCustomer"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.get_customer_by_cpf.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "arn:${data.aws_partition.current.partition}:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${data.terraform_remote_state.infra.outputs.api_gateway_id}/*/*"
# }
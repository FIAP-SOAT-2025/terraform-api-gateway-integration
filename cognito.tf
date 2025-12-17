# resource "aws_cognito_user_pool" "customer_pool" {
#   name = "lanchonete-customer-pool"

#   schema {
#     name = "cpf"
#     attribute_data_type = "String"
#     mutable             = false
#     required            = false 
#     string_attribute_constraints {
#       min_length = 11
#       max_length = 11
#     }
#   }
#   schema {
#     name = "nome"
#     attribute_data_type = "String"
#     mutable             = false
#     required            = false
#   }

#   auto_verified_attributes = ["email"]

#   tags = {
#     Project = "Lanchonete"
#   }
# }

# resource "aws_cognito_user_pool_client" "api_client" {
#   name                                 = "api-gateway-client"
#   user_pool_id                         = aws_cognito_user_pool.customer_pool.id
#   generate_secret                      = false
#   explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH"]
#   prevent_user_existence_errors        = "ENABLED"
#   enable_token_revocation              = true
#   access_token_validity                = 1
#   id_token_validity                    = 1
#   refresh_token_validity               = 30
# }
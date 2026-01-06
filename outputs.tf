output "api_gateway_id" {
  description = "ID do API Gateway que está sendo usado para a integração."
  value       = data.terraform_remote_state.infra.outputs.api_gateway_id
}

# output "api_gateway_target_hostname" {
#   description = "Hostname do Load Balancer para o qual o API Gateway está apontando."
#   value       = data.terraform_remote_state.api.outputs.api_load_balancer_hostname
# }

# output "integration_id" {
#   description = "ID da integração criada."
#   value       = aws_apigatewayv2_integration.lanchonete_integration.id
# }

output "api_gateway_invoke_url" {
  description = "URL de invocação do API Gateway (do módulo de infraestrutura)."
  value       = data.terraform_remote_state.infra.outputs.api_gateway_url
}

# output "DEBUG_load_balancer_hostname_from_api_state" {
#   description = "VALOR DE DEBUG: Mostra o hostname lido do estado remoto da API."
#   value       = data.terraform_remote_state.api.outputs.api_load_balancer_hostname
#   sensitive   = false
# }
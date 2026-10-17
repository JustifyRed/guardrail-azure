output "tenant_id" {
  description = "Set as GitHub repo variable AZURE_TENANT_ID."
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "Set as GitHub repo variable AZURE_SUBSCRIPTION_ID."
  value       = var.subscription_id
}

output "plan_client_id" {
  description = "Set as GitHub repo variable AZURE_PLAN_CLIENT_ID."
  value       = azuread_application.plan.client_id
}

output "deploy_client_id" {
  description = "Set as GitHub ENVIRONMENT variable AZURE_DEPLOY_CLIENT_ID on the production environment."
  value       = azuread_application.deploy.client_id
}

output "state_resource_group" {
  value = azurerm_resource_group.state.name
}

output "state_storage_account" {
  description = "Set as GitHub repo variable TF_STATE_STORAGE_ACCOUNT."
  value       = azurerm_storage_account.state.name
}

output "state_container" {
  value = azurerm_storage_container.state.name
}

output "github_variables_commands" {
  description = "Copy-paste gh CLI commands to configure the repository."
  value       = <<-EOT
    gh variable set AZURE_TENANT_ID          --body "${data.azurerm_client_config.current.tenant_id}"
    gh variable set AZURE_SUBSCRIPTION_ID    --body "${var.subscription_id}"
    gh variable set AZURE_PLAN_CLIENT_ID     --body "${azuread_application.plan.client_id}"
    gh variable set TF_STATE_STORAGE_ACCOUNT --body "${azurerm_storage_account.state.name}"
    gh variable set AZURE_DEPLOY_CLIENT_ID   --env ${var.deploy_environment} --body "${azuread_application.deploy.client_id}"
  EOT
}

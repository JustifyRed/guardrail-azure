output "resource_group_name" {
  value = azurerm_resource_group.ops.name
}

output "action_group_id" {
  description = "Consumed by the alerting module (Week 5)."
  value       = azurerm_monitor_action_group.ops.id
}

output "budget_id" {
  value = azurerm_consumption_budget_subscription.monthly.id
}

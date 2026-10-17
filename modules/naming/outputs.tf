output "tags" {
  description = "Mandatory tag map every resource must carry."
  value       = local.mandatory_tags
}

output "resource_group" {
  value = "rg-${local.base}"
}

output "log_analytics" {
  value = "log-${local.base}"
}

output "key_vault" {
  description = "Key Vault names are global and max 24 chars; a random suffix is appended by the key-vault module."
  value       = substr("kv-${replace(local.base, "-", "")}", 0, 18)
}

output "vnet_hub" {
  value = "vnet-hub-${local.base}"
}

output "vnet_spoke" {
  value = "vnet-spoke-${local.base}"
}

output "action_group" {
  value = "ag-${local.base}"
}

output "budget" {
  value = "budget-${local.base}"
}

output "base" {
  value = local.base
}

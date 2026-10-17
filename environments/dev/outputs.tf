output "ops_resource_group" {
  value = module.cost_guard.resource_group_name
}

output "mandatory_tags" {
  value = module.naming.tags
}

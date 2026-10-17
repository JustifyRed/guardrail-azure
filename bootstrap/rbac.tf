############################################################
# Least-privilege role assignments (AC-6).
# Deliberately NOT "Owner" on either identity.
############################################################

locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"
}

# ---------- Plan identity ----------
resource "azurerm_role_assignment" "plan_reader" {
  scope                = local.subscription_scope
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.plan.object_id
}

# Plan must take a blob lease to lock state, so it needs data-plane write on
# the state container only — not the whole account, not the subscription.
resource "azurerm_role_assignment" "plan_state" {
  scope                = azurerm_storage_container.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.plan.object_id
}

# ---------- Deploy identity ----------
resource "azurerm_role_assignment" "deploy_contributor" {
  scope                = local.subscription_scope
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.deploy.object_id
}

# Needed to create policy definitions, initiatives and assignments (Week 4).
resource "azurerm_role_assignment" "deploy_policy" {
  scope                = local.subscription_scope
  role_definition_name = "Resource Policy Contributor"
  principal_id         = azuread_service_principal.deploy.object_id
}

# Needed for Key Vault RBAC and policy managed identities. Constrained by an
# ABAC condition so the pipeline can never grant Owner, User Access
# Administrator or RBAC Administrator — i.e. it cannot escalate itself.
resource "azurerm_role_assignment" "deploy_rbac_admin" {
  scope                = local.subscription_scope
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azuread_service_principal.deploy.object_id
  condition_version    = "2.0"
  condition            = <<-EOT
    (
      (
        !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
      )
      OR
      (
        @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}
      )
    )
    AND
    (
      (
        !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
      )
      OR
      (
        @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}
      )
    )
  EOT
}

resource "azurerm_role_assignment" "deploy_state" {
  scope                = azurerm_storage_container.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.deploy.object_id
}

# The human running bootstrap also needs data-plane access to migrate state.
resource "azurerm_role_assignment" "operator_state" {
  scope                = azurerm_storage_container.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

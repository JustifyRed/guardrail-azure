############################################################
# Remote state backend — hardened from day one.
# Controls: SC-8 / SC-28 (TLS 1.2, encryption at rest),
#           AC-3 / IA-2 (Entra ID auth only, shared keys disabled),
#           CP-9 (blob versioning + soft delete for state recovery)
############################################################

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_resource_group" "state" {
  name     = "rg-guardrail-tfstate"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "state" {
  # Accepted risks — each is tracked in docs/poam.md with a production remediation:
  #checkov:skip=CKV_AZURE_59:POAM-001 GitHub-hosted runners have no fixed egress IPs; access is Entra-ID-only (shared keys disabled). See ADR-0003.
  #checkov:skip=CKV2_AZURE_33:POAM-001 Private endpoint requires self-hosted runners in a VNet (cost). See ADR-0003.
  #checkov:skip=CKV_AZURE_206:POAM-002 LRS chosen for free-tier cost; blob versioning + 30-day soft delete provide recovery.
  #checkov:skip=CKV2_AZURE_1:POAM-003 Customer-managed key adds Key Vault dependency to the bootstrap; Microsoft-managed keys + infrastructure encryption used.
  #checkov:skip=CKV_AZURE_33:POAM-004 Queue service is not used by this account.
  name                = "stguardrailtf${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location

  account_tier             = "Standard"
  account_replication_type = "LRS" # GRS in production; LRS keeps this inside free amounts
  account_kind             = "StorageV2"

  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  shared_access_key_enabled         = false # Entra ID auth only — no account keys in use anywhere
  default_to_oauth_authentication   = true
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = true # GitHub-hosted runners have no fixed IPs; see ADR-0003
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

# Created through the management plane (storage_account_id) so it works with
# shared keys disabled and before any data-plane role assignment propagates.
resource "azurerm_storage_container" "state" {
  #checkov:skip=CKV2_AZURE_21:POAM-005 Blob read logging is wired to Log Analytics in Week 3 (monitoring module); scheduled closure tracked in docs/poam.md.
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

resource "azurerm_management_lock" "state" {
  name       = "lock-tfstate-cannot-delete"
  scope      = azurerm_storage_account.state.id
  lock_level = "CanNotDelete"
  notes      = "Protects Terraform state. Remove deliberately, never by accident."
}

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.10"
    }
  }

  # Values for storage_account_name come from -backend-config in CI
  # (see .github/workflows) so the backend is never hard-coded.
  backend "azurerm" {
    resource_group_name = "rg-guardrail-tfstate"
    container_name      = "tfstate"
    key                 = "dev.tfstate"
    use_azuread_auth    = true
    use_oidc            = true
  }
}

provider "azurerm" {
  subscription_id     = var.subscription_id
  storage_use_azuread = true
  use_oidc            = true

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

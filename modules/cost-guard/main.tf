############################################################
# cost-guard — deployed FIRST; every other module depends on it.
# A budget alert exists before anything that can cost money.
############################################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.11"
    }
  }
}

resource "azurerm_resource_group" "ops" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_monitor_action_group" "ops" {
  name                = var.action_group_name
  resource_group_name = azurerm_resource_group.ops.name
  short_name          = "guardrail"
  tags                = var.tags

  email_receiver {
    name                    = "owner"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = var.budget_name
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.monthly_budget_usd
  time_grain      = "Monthly"

  time_period {
    # Budgets require a start date on the first of a month.
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", plantimestamp())
  }

  dynamic "notification" {
    for_each = var.actual_thresholds
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThanOrEqualTo"
      threshold_type = "Actual"
      contact_groups = [azurerm_monitor_action_group.ops.id]
      contact_emails = [var.alert_email]
    }
  }

  # Forecast alert warns BEFORE money is actually spent.
  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Forecasted"
    contact_groups = [azurerm_monitor_action_group.ops.id]
    contact_emails = [var.alert_email]
  }

  lifecycle {
    # plantimestamp() changes every run; the start date must not churn.
    ignore_changes = [time_period]
  }
}

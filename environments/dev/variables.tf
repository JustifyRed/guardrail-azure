variable "subscription_id" {
  description = "Supplied by CI as TF_VAR_subscription_id."
  type        = string
}

variable "alert_email" {
  description = "Supplied by CI as TF_VAR_alert_email from a GitHub secret."
  type        = string
  sensitive   = true
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "region_short" {
  type    = string
  default = "eus"
}

variable "owner" {
  type = string
}

variable "monthly_budget_usd" {
  type    = number
  default = 5
}

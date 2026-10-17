variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "action_group_name" {
  type = string
}

variable "budget_name" {
  type = string
}

variable "alert_email" {
  description = "Personal email for budget and security alerts. Never a .mil address."
  type        = string
  sensitive   = true

  validation {
    condition     = !endswith(lower(var.alert_email), ".mil")
    error_message = "Use a personal address. GUARDRAIL is a personal project and must not route to government systems."
  }
}

variable "monthly_budget_usd" {
  description = "Monthly budget ceiling in USD."
  type        = number
  default     = 5
}

variable "actual_thresholds" {
  description = "Percent-of-budget thresholds for actual-spend alerts."
  type        = list(number)
  default     = [50, 80, 100]
}

variable "tags" {
  type = map(string)
}

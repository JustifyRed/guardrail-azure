variable "workload" {
  description = "Short workload name, lowercase letters and digits only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.workload))
    error_message = "workload must be 3-10 lowercase letters or digits."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "region_short" {
  description = "Short region code used in names, e.g. eus for eastus."
  type        = string
}

variable "owner" {
  description = "Accountable owner (person or team)."
  type        = string
}

variable "data_classification" {
  description = "Highest data classification the environment may hold."
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "confidential"], var.data_classification)
    error_message = "data_classification must be public, internal or confidential. GUARDRAIL never hosts government-classified or CUI data."
  }
}

variable "cost_center" {
  description = "Cost center tag value."
  type        = string
  default     = "portfolio"
}

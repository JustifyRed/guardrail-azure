variable "subscription_id" {
  description = "Azure subscription ID that GUARDRAIL deploys into."
  type        = string
}

variable "location" {
  description = "Azure region for the state backend. Must also be on the allowed-locations policy list."
  type        = string
  default     = "eastus"
}

variable "github_owner" {
  description = "GitHub user or organization that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without owner)."
  type        = string
  default     = "guardrail-azure"
}

variable "github_owner_id" {
  description = "Immutable numeric ID of the GitHub owner: `gh api users/<owner> --jq .id`."
  type        = number
}

variable "github_repo_id" {
  description = "Immutable numeric ID of the repository: `gh api repos/<owner>/<repo> --jq .id`."
  type        = number
}

variable "deploy_environment" {
  description = "GitHub Environment name that gates terraform apply. Must match cd.yml."
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Mandatory tags applied to bootstrap resources."
  type        = map(string)
  default = {
    project             = "guardrail"
    environment         = "shared"
    owner               = "platform"
    data_classification = "internal"
    managed_by          = "terraform-bootstrap"
  }
}

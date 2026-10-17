############################################################
# GitHub Actions OIDC identities — no client secrets exist.
# Two identities enforce separation of duties (AC-5, AC-6):
#   plan   : read-only, used by PRs, pushes and drift detection
#   deploy : write, usable ONLY from the gated GitHub Environment
############################################################

locals {
  repo   = "${var.github_owner}/${var.github_repo}"
  issuer = "https://token.actions.githubusercontent.com"
  aud    = ["api://AzureADTokenExchange"]
}

# ---------- Plan identity (read-only) ----------
resource "azuread_application" "plan" {
  display_name = "sp-guardrail-github-plan"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "plan" {
  client_id = azuread_application.plan.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_federated_identity_credential" "plan_pr" {
  application_id = azuread_application.plan.id
  display_name   = "github-pull-requests"
  description    = "Terraform plan on pull requests"
  issuer         = local.issuer
  audiences      = local.aud
  subject        = "repo:${local.repo}:pull_request"
}

resource "azuread_application_federated_identity_credential" "plan_main" {
  application_id = azuread_application.plan.id
  display_name   = "github-main-branch"
  description    = "Terraform plan on main and nightly drift detection"
  issuer         = local.issuer
  audiences      = local.aud
  subject        = "repo:${local.repo}:ref:refs/heads/main"
}

# ---------- Deploy identity (write, environment-gated) ----------
resource "azuread_application" "deploy" {
  display_name = "sp-guardrail-github-deploy"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "deploy" {
  client_id = azuread_application.deploy.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

# The ONLY subject this identity trusts is the protected environment, so a
# feature branch or a PR can never obtain write credentials.
resource "azuread_application_federated_identity_credential" "deploy_env" {
  application_id = azuread_application.deploy.id
  display_name   = "github-env-${var.deploy_environment}"
  description    = "Terraform apply/destroy behind required-reviewer approval"
  issuer         = local.issuer
  audiences      = local.aud
  subject        = "repo:${local.repo}:environment:${var.deploy_environment}"
}

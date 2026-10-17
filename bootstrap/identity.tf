############################################################
# GitHub Actions OIDC identities — no client secrets exist.
# Two identities enforce separation of duties (AC-5, AC-6):
#   plan   : read-only, used by PRs, pushes and drift detection
#   deploy : write, usable ONLY from the gated GitHub Environment
############################################################

locals {
  # GitHub's OIDC subject embeds immutable numeric IDs for the owner and repo:
  #   repo:<owner>@<owner_id>/<repo>@<repo_id>:<context>
  # Trusting IDs (not just names) means a deleted-and-recreated repo with the
  # same name can never inherit this Azure trust. See ADR-0001.
  subject_prefix = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"
  issuer         = "https://token.actions.githubusercontent.com"
  aud            = ["api://AzureADTokenExchange"]
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
  #checkov:skip=CKV_AZURE_249:POAM-007 False positive — Checkov 3.3.x repo regex predates GitHub immutable-ID subjects (owner@id/repo@id). Subject is fully specific; no wildcards.
  application_id = azuread_application.plan.id
  display_name   = "github-pull-requests"
  description    = "Terraform plan on pull requests"
  issuer         = local.issuer
  audiences      = local.aud
  subject        = "${local.subject_prefix}:pull_request"
}

resource "azuread_application_federated_identity_credential" "plan_main" {
  #checkov:skip=CKV_AZURE_249:POAM-007 False positive — Checkov 3.3.x repo regex predates GitHub immutable-ID subjects (owner@id/repo@id). Subject is fully specific; no wildcards.
  application_id = azuread_application.plan.id
  display_name   = "github-main-branch"
  description    = "Terraform plan on main and nightly drift detection"
  issuer         = local.issuer
  audiences      = local.aud
  subject        = "${local.subject_prefix}:ref:refs/heads/main"
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
  #checkov:skip=CKV_AZURE_249:POAM-007 False positive — Checkov 3.3.x repo regex predates GitHub immutable-ID subjects (owner@id/repo@id). Subject is fully specific; no wildcards.
  application_id = azuread_application.deploy.id
  display_name   = "github-env-${var.deploy_environment}"
  description    = "Terraform apply/destroy behind required-reviewer approval"
  issuer         = local.issuer
  audiences      = local.aud
  subject        = "${local.subject_prefix}:environment:${var.deploy_environment}"
}

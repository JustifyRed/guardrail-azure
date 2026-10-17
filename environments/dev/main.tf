############################################################
# GUARDRAIL — dev environment composition.
# Week 1: naming + cost-guard. Each later week adds one module
# block below and nothing else changes.
############################################################

module "naming" {
  source = "../../modules/naming"

  workload     = "guardrail"
  environment  = "dev"
  region_short = var.region_short
  owner        = var.owner
}

module "cost_guard" {
  source = "../../modules/cost-guard"

  subscription_id     = var.subscription_id
  location            = var.location
  resource_group_name = "${module.naming.resource_group}-ops"
  action_group_name   = module.naming.action_group
  budget_name         = module.naming.budget
  alert_email         = var.alert_email
  monthly_budget_usd  = var.monthly_budget_usd
  tags                = module.naming.tags
}

# Week 3 — uncomment as each module lands:
# module "monitoring"     { source = "../../modules/monitoring"     ... depends_on = [module.cost_guard] }
# module "networking"     { source = "../../modules/networking"     ... }
# module "key_vault"      { source = "../../modules/key-vault"      ... }
# module "secure_storage" { source = "../../modules/secure-storage" ... }
# Week 4:
# module "governance"     { source = "../../modules/governance"     ... }
# module "defender"       { source = "../../modules/defender"       ... }
# Week 5:
# module "alerting"       { source = "../../modules/alerting"       ... }

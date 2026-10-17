config {
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Check https://github.com/terraform-linters/tflint-ruleset-azurerm/releases
# for the latest version and bump here (Dependabot does not track this file).
plugin "azurerm" {
  enabled = true
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = false # enabled in Phase 2 when modules are published
}

############################################################
# naming — single source of truth for names and mandatory tags.
# The governance module (Week 4) enforces these same tag keys
# with a deny policy, so skipping this module fails deployment.
# Control: CM-8 (system component inventory)
############################################################

terraform {
  required_version = ">= 1.9.0"
}

locals {
  base = "${var.workload}-${var.environment}-${var.region_short}"

  mandatory_tags = {
    project             = var.workload
    environment         = var.environment
    owner               = var.owner
    data_classification = var.data_classification
    cost_center         = var.cost_center
    managed_by          = "terraform"
  }
}

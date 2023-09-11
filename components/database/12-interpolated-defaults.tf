locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  is_prod = length(regexall(".*(prod).*", var.env)) > 0
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_subnet" "backend-postgresql" {
  name                 = "crime-portal-backend-postgresql-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_client_config" "current" {}

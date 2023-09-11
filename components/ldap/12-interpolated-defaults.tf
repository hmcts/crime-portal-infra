locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  is_prod             = length(regexall(".*(prod).*", var.env)) > 0
  resource_group_name = "crime-portal-rg-${var.env}"
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_subnet" "backend" {
  name                 = "crime-portal-backend-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "vault" {
  name                = "crime-portal-kv-${var.env}"
  resource_group_name = local.resource_group_name
}

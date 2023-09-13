locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  resource_group_name = "crime-portal-rg-${var.env}"
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_subnet" "frontend" {
  name                 = "crime-portal-frontend-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_key_vault" "vault" {
  name                = "crime-portal-kv-${var.env}"
  resource_group_name = local.resource_group_name
}

data "azurerm_backup_policy_vm" "policy" {
  name                = "crime-portal-daily-bp-${var.env}"
  recovery_vault_name = "crime-portal-rsv-${var.env}"
  resource_group_name = local.resource_group_name
}

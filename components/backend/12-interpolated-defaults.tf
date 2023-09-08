locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  is_prod     = length(regexall(".*(prod).*", var.env)) > 0
  admin_group = local.is_prod ? "DTS Platform Operations SC" : "DTS Platform Operations"
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

data "azuread_group" "admin_group" {
  display_name     = local.admin_group
  security_enabled = true
}

data "azurerm_client_config" "current" {}

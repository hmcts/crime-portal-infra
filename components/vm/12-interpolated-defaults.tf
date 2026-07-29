locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }

  xdr_tag_map = {
    activityName = "heritage"
    application  = "crimeportal"
    env          = var.env == "stg" ? "nonprod" : var.env
  }

  xdr_tags = join(",", values(local.xdr_tag_map))

  resource_group_name              = "crime-portal-rg-${var.env}"
  virtual_machines                 = merge(var.frontend_vms, var.ldap_vms)
  azure_reserved_ip_address_offset = 4
}



module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_subnet" "subnets" {
  for_each             = local.virtual_machines
  name                 = "crime-portal-${each.value.subnet_name}-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_key_vault" "vault" {
  name                = "crime-portal-kv-${var.env}"
  resource_group_name = local.resource_group_name
}

// DTSPO-32146: baseline policy is Terraform-managed for prod only (see 26-backup-policy.tf).
// stg keeps its existing out-of-band policy, looked up here via data source, unchanged.
data "azurerm_backup_policy_vm" "policy" {
  count               = var.env == "prod" ? 0 : 1
  name                = "crime-portal-daily-bp-${var.env}"
  recovery_vault_name = "crime-portal-rsv-${var.env}"
  resource_group_name = local.resource_group_name
}

data "azurerm_storage_account" "xdr_storage" {
  provider            = azurerm.DTS-CFTPTL-INTSVC
  name                = "cftptlintsvc"
  resource_group_name = "core-infra-intsvc-rg"
}

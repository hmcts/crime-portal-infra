locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  is_prod             = length(regexall(".*(prod).*", var.env)) > 0
  resource_group_name = "crime-portal-rg-${var.env}"

  flattened_ldap_users = flatten([
    for user_key, user in var.ldap_users : [
      for ldap_vm_key, ldap_vm in var.ldap_vms : {
        user_key = user_key
        user     = user
        vm_key   = ldap_vm_key
        vm_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${ldap_vm_key}"
      }
    ]
  ])

  flattened_frontend_users = flatten([
    for user_key, user in var.frontend_users : [
      for frontend_vm_key, frontend_vm in var.frontend_vms : {
        user_key = user_key
        user     = user
        vm_key   = frontend_vm_key
        vm_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${frontend_vm_key}"
      }
    ]
  ])
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_client_config" "current" {}

data "azuread_user" "ldap_users" {
  for_each            = { for key, value in var.ldap_users : key => value if value.is_user == true }
  user_principal_name = each.key
}

data "azuread_group" "ldap_groups" {
  for_each         = { for key, value in var.ldap_users : key => value if value.is_group == true }
  display_name     = each.key
  security_enabled = each.value.group_security_enabled
}

data "azuread_service_principal" "ldap_sps" {
  for_each     = { for key, value in var.ldap_users : key => value if value.is_service_principal == true }
  display_name = each.key
}

data "azuread_user" "frontend_users" {
  for_each            = { for key, value in var.frontend_users : key => value if value.is_user == true }
  user_principal_name = each.key
}

data "azuread_group" "frontend_groups" {
  for_each         = { for key, value in var.frontend_users : key => value if value.is_group == true }
  display_name     = each.key
  security_enabled = each.value.group_security_enabled
}

data "azuread_service_principal" "frontend_sps" {
  for_each     = { for key, value in var.frontend_users : key => value if value.is_service_principal == true }
  display_name = each.key
}

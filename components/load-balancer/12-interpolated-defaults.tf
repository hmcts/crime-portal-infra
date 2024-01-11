locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  resource_group_name = "crime-portal-rg-${var.env}"
  flattened_backend_ip_addresses = flatten([
    for pool_key, pool in var.load_balancer.backend_address_pools : [
      for ip_key, ip in pool.ip_addresses : {
        pool_key = pool_key
        ip_key   = ip_key
        ip       = ip
      }
    ]
  ])
  flattened_backend_vm_ip_addresses = flatten([
    for pool_key, pool in var.load_balancer.backend_address_pools : [
      for vm_name in pool.virtual_machine_names : {
        pool_key = pool_key
        key      = "${pool_key}-${vm_name}"
        vm_name  = vm_name
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

data "azurerm_subscription" "current" {}

data "azurerm_subnet" "frontend_subnets" {
  for_each             = var.load_balancer.frontend_ip_configurations
  name                 = "crime-portal-${each.value.subnet_name}-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_virtual_machine" "backend_vm" {
  for_each            = { for value in local.flattened_backend_vm_ip_addresses : value.key => value.vm_name }
  name                = each.value
  resource_group_name = local.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name = "InternalSpoke-rg"
}

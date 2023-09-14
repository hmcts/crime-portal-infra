locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  resource_group_name   = "crime-portal-rg-${var.env}"
  x_fwded_proto_ruleset = "x_fwded_proto"
  flattened_gateway_ip_configurations = flatten([
    for appgw_key, appgw in var.app_gateways : [
      for gateway_ip_config_key, gateway_ip_config in appgw.gateway_ip_configurations : {
        appgw_key             = appgw_key
        gateway_ip_config_key = gateway_ip_config_key
        subnet_name           = gateway_ip_config.subnet_name
      }
    ]
  ])
  flattened_frontend_ip_configurations = flatten([
    for appgw_key, appgw in var.app_gateways : [
      for frontend_ip_configuration_key, frontend_ip_configuration in appgw.frontend_ip_configurations : {
        appgw_key                     = appgw_key
        frontend_ip_configuration_key = frontend_ip_configuration_key
        subnet_name                   = frontend_ip_configuration.subnet_name
      }
    ]
  ])
  flattened_backend_vms = flatten([
    for appgw_key, appgw in var.app_gateways : [
      for backend_pool_key, backend_pool in appgw.backend_address_pools : [
        for virtual_machine_name in backend_pool.virtual_machine_names : {
          appgw_key            = appgw_key
          backend_pool_key     = backend_pool_key
          virtual_machine_name = virtual_machine_name
        }
      ]
    ]
  ])
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_subnet" "appgw" {
  name                 = "crime-portal-appgw-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_subnet" "gateway_subnets" {
  for_each             = { for gateway_ip_config in local.flattened_gateway_ip_configurations : "${gateway_ip_config.appgw_key}-${gateway_ip_config.gateway_ip_config_key}" => gateway_ip_config }
  name                 = "crime-portal-${each.value.subnet_name}-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_subnet" "frontend_subnets" {
  for_each             = { for frontend_ip_configuration in local.flattened_frontend_ip_configurations : "${frontend_ip_configuration.appgw_key}-${frontend_ip_configuration.frontend_ip_configuration_key}" => frontend_ip_configuration }
  name                 = "crime-portal-${each.value.subnet_name}-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_virtual_machine" "backend_vms" {
  for_each            = { for virtual_machine_name in local.flattened_backend_vms : "${virtual_machine_name.appgw_key}-${virtual_machine_name.virtual_machine_name}" => virtual_machine_name }
  name                = each.value.virtual_machine_name
  resource_group_name = local.resource_group_name
}

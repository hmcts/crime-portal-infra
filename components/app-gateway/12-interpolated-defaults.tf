locals {
  env_map = {
    "stg"  = "nle"
    "prod" = "prod"
  }
  resource_group_name   = "crime-portal-rg-${var.env}"
  acme_resource_group   = "cft-platform-ptl-rg"
  x_fwded_proto_ruleset = "x_fwded_proto"
  flattened_gateway_ip_configurations = flatten([
    for gateway_ip_config_key, gateway_ip_config in var.app_gateway.gateway_ip_configurations : {
      gateway_ip_config_key = gateway_ip_config_key
      subnet_name           = gateway_ip_config.subnet_name
    }
  ])
  flattened_frontend_ip_configurations = flatten([
    for frontend_ip_configuration_key, frontend_ip_configuration in var.app_gateway.frontend_ip_configurations : {
      frontend_ip_configuration_key = frontend_ip_configuration_key
      subnet_name                   = frontend_ip_configuration.subnet_name
      public_ip_address_name        = frontend_ip_configuration.public_ip_address_name
    }
  ])
  flattened_backend_vms = flatten([
    for backend_pool_key, backend_pool in var.app_gateway.backend_address_pools : [
      for virtual_machine_name in backend_pool.virtual_machine_names : {
        backend_pool_key     = backend_pool_key
        virtual_machine_name = virtual_machine_name
      }
    ]
  ])
  trusted_root_certificates = flatten([
    for trusted_cert_key, trusted_cert in var.app_gateway.trusted_root_certificates : {
      trusted_cert_key = trusted_cert_key
      secret_name      = trusted_cert
    }
  ])
  ssl_certificates = flatten([
    for ssl_cert_key, ssl_cert in var.app_gateway.ssl_certificates : {
      ssl_cert_key  = ssl_cert_key
      ssl_cert_name = ssl_cert
    }
  ])
}

data "azurerm_client_config" "current" {}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_subnet" "gateway_subnets" {
  for_each             = { for gateway_ip_config in local.flattened_gateway_ip_configurations : "${gateway_ip_config.gateway_ip_config_key}" => gateway_ip_config }
  name                 = "crime-portal-${each.value.subnet_name}-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_subnet" "frontend_subnets" {
  for_each             = { for frontend_ip_configuration in local.flattened_frontend_ip_configurations : "${frontend_ip_configuration.frontend_ip_configuration_key}" => frontend_ip_configuration if frontend_ip_configuration.subnet_name != null }
  name                 = "crime-portal-${each.value.subnet_name}-${var.env}"
  virtual_network_name = "vnet-${local.env_map[var.env]}-int-01"
  resource_group_name  = "InternalSpoke-rg"
}

data "azurerm_virtual_machine" "backend_vms" {
  for_each            = { for virtual_machine_name in local.flattened_backend_vms : "${virtual_machine_name.virtual_machine_name}" => virtual_machine_name }
  name                = each.value.virtual_machine_name
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "root_certificates" {
  for_each     = { for trusted_cert in local.trusted_root_certificates : "${trusted_cert.trusted_cert_key}" => trusted_cert }
  name         = each.value.secret_name
  key_vault_id = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.KeyVault/vaults/crime-portal-kv-${var.env}"
}


data "azurerm_key_vault" "acme_kv" {
  provider            = azurerm.acme
  name                = var.app_gateway.ssl_certificates["certificate"].key_vault_name
  resource_group_name = local.acme_resource_group
}

data "azurerm_key_vault_certificate" "certificate" {
  name         = var.app_gateway.ssl_certificates["certificate"].certificate_name
  key_vault_id = data.azurerm_key_vault.acme_kv.id
}
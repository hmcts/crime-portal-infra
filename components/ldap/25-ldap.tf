resource "random_string" "vm_username" {
  for_each = var.ldap_vms
  length   = 4
  special  = false
}

resource "random_password" "vm_password" {
  for_each         = var.ldap_vms
  length           = 16
  special          = true
  override_special = "#$%&@()_[]{}<>:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

resource "azurerm_key_vault_secret" "vm_username_secret" {
  for_each     = var.ldap_vms
  name         = "${each.key}-vm-username-${var.env}"
  value        = random_string.vm_username[each.key].result
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "vm_password_secret" {
  for_each     = var.ldap_vms
  name         = "${each.key}-vm-password-${var.env}"
  value        = random_password.vm_password[each.key].result
  key_vault_id = data.azurerm_key_vault.vault.id
}

module "virtual_machine" {
  for_each = var.ldap_vms

  source = "git::https://github.com/hmcts/terraform-module-virtual-machine.git?ref=master"

  providers = {
    azurerm     = azurerm
    azurerm.soc = azurerm.soc
    azurerm.cnp = azurerm.cnp
  }

  env                  = var.env == "stg" ? "nonprod" : var.env
  vm_type              = "linux"
  vm_name              = each.key
  vm_resource_group    = local.resource_group_name
  vm_admin_name        = random_string.vm_username[each.key].result
  vm_admin_password    = random_password.vm_password[each.key].result
  vm_subnet_id         = data.azurerm_subnet.backend.id
  vm_publisher_name    = "RedHat"
  vm_offer             = "RHEL"
  vm_sku               = "79-gen2"
  vm_size              = "Standard_D2ds_v5"
  vm_version           = "latest"
  vm_availabilty_zones = each.value.availability_zone
  tags                 = module.ctags.common_tags
  privateip_allocation = "Dynamic"

  install_azure_monitor      = true
  install_dynatrace_oneagent = true
  install_splunk_uf          = true
  nessus_install             = true

  custom_script_extension_name = "HMCTSVMBootstrap"
}

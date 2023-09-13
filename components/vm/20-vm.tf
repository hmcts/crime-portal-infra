resource "random_string" "vm_username" {
  for_each = var.frontend_vms
  length   = 4
  special  = false
}

resource "random_password" "vm_password" {
  for_each         = var.frontend_vms
  length           = 16
  special          = true
  override_special = "#$%&@()_[]{}<>:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

resource "azurerm_key_vault_secret" "vm_username_secret" {
  for_each     = var.frontend_vms
  name         = "${each.key}-vm-username-${var.env}"
  value        = random_string.vm_username[each.key].result
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "vm_password_secret" {
  for_each     = var.frontend_vms
  name         = "${each.key}-vm-password-${var.env}"
  value        = random_password.vm_password[each.key].result
  key_vault_id = data.azurerm_key_vault.vault.id
}

module "vm_app" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }

  for_each             = var.frontend_vms
  source               = "github.com/hmcts/terraform-module-virtual-machine.git"
  vm_type              = "linux"
  vm_name              = each.key
  env                  = var.env == "stg" ? "nonprod" : var.env
  vm_resource_group    = local.resource_group_name
  vm_location          = var.location
  vm_admin_name        = random_string.vm_username[each.key].result
  vm_admin_password    = random_password.vm_password[each.key].result
  vm_availabilty_zones = each.value.availability_zone
  vm_subnet_id         = data.azurerm_subnet.frontend.id
  vm_publisher_name    = "RedHat"
  vm_offer             = "RHEL"
  vm_sku               = "79-gen2"
  vm_size              = "Standard_D2ds_v5"
  vm_version           = "latest"
  privateip_allocation = "Dynamic"

  install_azure_monitor      = true
  install_dynatrace_oneagent = true
  install_splunk_uf          = true
  nessus_install             = true

  custom_script_extension_name = "HMCTSVMBootstrap"
  tags                         = module.ctags.common_tags
}

resource "azurerm_backup_protected_vm" "vm" {
  for_each            = var.frontend_vms
  resource_group_name = var.resource_group
  recovery_vault_name = var.azurerm_recovery_services_vault_name
  source_vm_id        = module.vm_app[each.key].vm_id
  backup_policy_id    = data.azurerm_backup_policy_vm.policy.id
}

resource "azurerm_virtual_machine_extension" "AADSSHLoginForLinux" {
  for_each                   = var.frontend_vms
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = module.vm_app[each.key].vm_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = module.ctags.common_tags
}

module "vm_app" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }
  count                = local.vm_count
  source               = "github.com/hmcts/terraform-module-virtual-machine.git"
  vm_type              = "linux"
  vm_name              = lower("crime-portal-vm${count.index + 1}-${var.env}")
  env                  = lower(var.env) == "prod" ? var.env : "nonprod"
  vm_resource_group    = var.resource_group
  vm_location          = var.location
  vm_admin_name        = "crime_portal${count.index + 1}_${random_string.vm_username.result}"
  vm_admin_password    = random_password.vm_password[count.index].result
  vm_availabilty_zones = local.vm_availability_zones[count.index]
  managed_disks        = var.vm_data_disks[count.index]
  vm_subnet_id         = data.azurerm_subnet.frontend.id
  vm_publisher_name    = "RedHat"
  vm_offer             = "RHEL"
  vm_sku               = "79-gen2"
  vm_size              = "Standard_D2ds_v5"
  vm_version           = "latest"
  privateip_allocation = "Dynamic"

  custom_script_extension_name = "HMCTSVMBootstrap"
  tags                         = module.ctags.common_tags
}

resource "azurerm_backup_protected_vm" "vm" {
  count               = local.vm_count
  resource_group_name = var.resource_group
  recovery_vault_name = var.azurerm_recovery_services_vault_name
  source_vm_id        = module.vm_app[count.index].vm_id
  backup_policy_id    = data.azurerm_backup_policy_vm.policy.id
}

resource "azurerm_virtual_machine_extension" "AADSSHLoginForLinux" {
  count                      = local.vm_count
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = module.vm_app[count.index].vm_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = module.ctags.common_tags
}

module "virtual-machines" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }

  for_each                = local.virtual_machines
  source                  = "github.com/hmcts/terraform-module-virtual-machine.git?ref=ama-extension"
  vm_type                 = "linux"
  vm_name                 = each.key
  env                     = var.env == "stg" ? "nonprod" : var.env
  vm_resource_group       = local.resource_group_name
  vm_location             = var.location
  vm_admin_name           = "crimeportal_${random_string.username[each.key].result}"
  vm_admin_password       = random_password.password[each.key].result
  vm_availabilty_zones    = each.value.availability_zone
  vm_subnet_id            = data.azurerm_subnet.subnets[each.key].id
  vm_publisher_name       = "canonical"
  vm_offer                = "0001-com-ubuntu-server-jammy"
  vm_sku                  = "22_04-lts-gen2"
  vm_size                 = each.value.size
  vm_version              = "latest"
  vm_private_ip           = each.value.private_ip != null ? each.value.private_ip : cidrhost(data.azurerm_subnet.subnets[each.key].address_prefixes[0], index(keys(local.virtual_machines), each.key) + local.azure_reserved_ip_address_offset)
  systemassigned_identity = true

  install_azure_monitor      = true
  install_dynatrace_oneagent = true
  install_splunk_uf          = true
  nessus_install             = true

  custom_script_extension_name = "HMCTSVMBootstrap"
  tags                         = module.ctags.common_tags
}

resource "azurerm_backup_protected_vm" "vm" {
  for_each            = local.virtual_machines
  resource_group_name = local.resource_group_name
  recovery_vault_name = "crime-portal-rsv-${var.env}"
  source_vm_id        = module.virtual-machines[each.key].vm_id
  backup_policy_id    = data.azurerm_backup_policy_vm.policy.id
}

resource "azurerm_virtual_machine_extension" "AADSSHLoginForLinux" {
  for_each                   = local.virtual_machines
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = module.virtual-machines[each.key].vm_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = module.ctags.common_tags
}

resource "azurerm_virtual_machine_extension" "install_docker" {
  for_each                   = var.frontend_vms
  name                       = "InstallDocker"
  virtual_machine_id         = module.virtual-machines[each.key].vm_id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  protected_settings = <<PROTECTED_SETTINGS
  {
    "script": "${filebase64("${path.module}/provision/install-docker.sh")}"
  }
  PROTECTED_SETTINGS

  tags = module.ctags.common_tags
}

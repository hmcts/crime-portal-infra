module "vm_app" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }
  count                = local.vm_count
  source               = "github.com/hmcts/terraform-module-virtual-machine.git"
  vm_type              = local.vm_type
  vm_name              = lower("crime-portal-vm${count.index + 1}-${var.env}")
  env                  = lower(var.env) == "prod" ? var.env : "nonprod"
  vm_resource_group    = var.resource_group
  vm_location          = var.location
  vm_size              = local.vm_size
  vm_admin_name        = "crime_portal${count.index + 1}_${random_string.vm_username.result}"
  vm_admin_password    = random_password.vm_password[count.index].result
  vm_availabilty_zones = local.vm_availability_zones[count.index]
  managed_disks        = var.vm_data_disks[count.index]

  #Disk Encryption
  kv_name     = var.key_vault_name
  kv_rg_name  = var.resource_group
  encrypt_ADE = false

  nic_name             = lower("crime-portal-vm${count.index + 1}-nic-${var.env}")
  dns_servers          = ["10.172.68.148", "10.172.68.149", "10.172.68.150", "10.171.68.148", "10.171.68.149", "10.171.68.150"]
  ipconfig_name        = local.ipconfig_name
  vm_subnet_id         = local.vm_subnet_id
  privateip_allocation = "Dynamic"

  #storage_image_reference
  vm_publisher_name = local.marketplace_publisher
  vm_offer          = local.marketplace_product
  vm_sku            = local.marketplace_sku
  vm_version        = local.vm_version

  boot_diagnostics_enabled = local.boot_diagnostics_enabled
  boot_storage_uri         = local.boot_storage_uri

  install_splunk_uf   = var.install_splunk_uf
  splunk_username     = try(data.azurerm_key_vault_secret.splunk_username[0].value, null)
  splunk_password     = try(data.azurerm_key_vault_secret.splunk_password[0].value, null)
  splunk_pass4symmkey = try(data.azurerm_key_vault_secret.splunk_pass4symmkey[0].value, null)

  nessus_install = var.nessus_install
  nessus_server  = var.nessus_server
  nessus_key     = try(data.azurerm_key_vault_secret.nessus_key[0].value, null)
  nessus_groups  = var.nessus_groups

  install_dynatrace_oneagent = true
  dynatrace_hostgroup        = var.hostgroup
  dynatrace_server           = var.server
  dynatrace_tenant_id        = var.tenant_id
  dynatrace_token            = try(data.azurerm_key_vault_secret.token[0].value, null)

  #this is to mount the disks
  additional_script_uri  = local.additional_script_uri
  additional_script_name = local.additional_script_name

  run_command    = var.run_command
  rc_script_file = var.rc_script_file

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

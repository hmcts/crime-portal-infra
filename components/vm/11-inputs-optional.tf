variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}

locals {
  vm_type = "linux"

  vm_size       = "Standard_D4ds_v5"
  ipconfig_name = "IP_CONFIGURATION"

  vm_subnet_id = data.azurerm_subnet.vm_subnet.id

  vm_availability_zones = [1, 2]
  marketplace_product   = "RHEL"
  marketplace_publisher = "RedHat"
  marketplace_sku       = "7.3"
  vm_version            = "7.3.2017090800"

  boot_diagnostics_enabled = true
  boot_storage_uri         = data.azurerm_storage_account.db_boot_diagnostics_storage.primary_blob_endpoint

  dynatrace_env = var.tenant_id == "yrk32651" ? "nonprod" : var.tenant_id == "ebe20728" ? "prod" : null

  vm_count = 2

  additional_script_uri  = "https://raw.githubusercontent.com/hmcts/CIS-harderning/master/windows-disk-mounting.ps1"
  additional_script_name = "windows-disk-mounting.ps1"
}
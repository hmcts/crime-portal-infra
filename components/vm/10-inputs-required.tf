variable "env" {
  type        = string
  description = "The environment to deploy resources to."
}

variable "builtFrom" {
  type        = string
  description = "The name of the repository these resources are builtFrom."
}

variable "product" {
  type        = string
  description = "The name of the prodcut this infrastructure supports."
}

variable "subnets" {
  type        = map(object({ address_prefixes = list(string), service_endpoints = optional(list(string), []) }))
  description = "Map of subnets to create."
}

//// VM Basic vars \\\\

variable "resource_group" {
  type        = string
  description = "Resource group for the VM"
}


//// VM Networking vars \\\\

variable "vnet_name" {
  type        = string
  description = "Name of the existing VNET"
}

variable "vnet_resource_group" {
  type        = string
  description = "Resource group the VNET is in"
}

variable "vm_subnet_name" {
  type        = string
  description = "Name of the subnet this VM is in"
}

data "azurerm_subnet" "vm_subnet" {
  name                 = var.vm_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group
}

variable "vm_private_ip" {
  type        = list(string)
  description = "Private IP(s) for the virtual machine"
}

//// VM Disk vars \\\\

variable "vm_data_disks" {
  type        = list(any)
  description = "list of disk configurations for each VM"
}

variable "boot_diag_storage_account_name" {
  type        = string
  description = "The name of the boot diagnostics storage account"
}

data "azurerm_storage_account" "db_boot_diagnostics_storage" {
  name                = var.boot_diag_storage_account_name
  resource_group_name = var.resource_group
}

//// VM Extension vars \\\\

# Splunk UF

variable "install_splunk_uf" {
  type        = bool
  default     = true
  description = "Install Splunk Universal Forwarder for this VM?"
}

data "azurerm_key_vault" "soc_vault" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name                = "soc-prod"
  resource_group_name = "soc-core-infra-prod-rg"
}

data "azurerm_key_vault_secret" "splunk_username" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name         = "splunk-gui-admin-username"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "splunk_password" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name         = "splunk-gui-admin-password"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "splunk_pass4symmkey" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name         = "Splunk-pass4SymmKey"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

# Azure Recovery Services

variable "azurerm_recovery_services_vault_name" {
  type        = string
  description = "Azure Recovery Services Vault for the VM"
}

variable "azurerm_backup_policy_vm_name" {
  type        = string
  description = "Azure Recovery Services backup policy for the VM"
}

# Dynatrace OA

variable "install_dynatrace_oa" {
  type        = bool
  default     = true
  description = "Install Dynatrace OneAgent for this VM?"
}

variable "cnp_vault_rg" {
  type        = string
  description = "Resource group for the CNP key vault"
}

variable "cnp_vault_sub" {
  type        = string
  description = "Subscription for the CNP key vault"
}

data "azurerm_key_vault" "cnp_vault" {
  count               = var.install_dynatrace_oa ? 1 : 0
  provider            = azurerm.cnp
  name                = "infra-vault-${local.dynatrace_env}"
  resource_group_name = var.cnp_vault_rg
}

data "azurerm_key_vault_secret" "token" {
  count    = var.install_dynatrace_oa ? 1 : 0
  provider = azurerm.cnp

  name         = "dynatrace-${local.dynatrace_env}-token"
  key_vault_id = data.azurerm_key_vault.cnp_vault[0].id
}

variable "tenant_id" {
  type        = string
  description = "Dynatrace tenant ID"
}

variable "hostgroup" {
  type        = string
  description = "Dynatrace hostgroup"
}

variable "server" {
  type        = string
  description = "Dynatrace server address"
}

# Nessus Agent

variable "nessus_install" {
  type        = bool
  default     = true
  description = "Install Nessus Agent for this VM?"
}

variable "nessus_server" {
  type        = string
  description = "Nessus server URL"
}

variable "nessus_key_name" {
  type        = string
  default     = null
  description = "Name of the secret containing the nessus key"
}

variable "nessus_groups" {
  type        = string
  description = "Nessus group for this VM"
}

data "azurerm_key_vault_secret" "nessus_key" {
  count        = var.nessus_install ? 1 : 0
  provider     = azurerm.soc
  name         = var.nessus_key_name
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

# Run command

variable "run_command" {
  type        = bool
  description = "Enable Azure Run Command for this VM?"
}

variable "rc_script_file" {
  type        = string
  description = "Path to the script file for Azure Run Command"
}

//// Password and Username \\\\

variable "key_vault_name" {
  type        = string
  description = "Key vault to store admin username and password secrets for this VM"
}
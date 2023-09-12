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

variable "cnp_vault_sub" {
  type        = string
  description = "Subscription for the CNP key vault"
}

//// VM Basic vars \\\\

variable "resource_group" {
  type        = string
  description = "Resource group for the VM"
}

//// VM Disk vars \\\\

variable "vm_data_disks" {
  type        = list(any)
  description = "list of disk configurations for each VM"
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

//// Password and Username \\\\

variable "key_vault_name" {
  type        = string
  description = "Key vault to store admin username and password secrets for this VM"
}
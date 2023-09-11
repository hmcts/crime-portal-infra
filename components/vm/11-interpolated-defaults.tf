module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

resource "random_string" "vm_username" {
  length  = 4
  special = false
}

resource "random_password" "vm_password" {
  count            = local.vm_count
  length           = 16
  special          = true
  override_special = "#$%&@()_[]{}<>:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

data "azurerm_key_vault" "crime_portal_vault" {

  name                = var.key_vault_name
  resource_group_name = var.resource_group
}

resource "azurerm_key_vault_secret" "vm_username_secret" {
  count        = local.vm_count
  name         = lower("crime-portal-vm${count.index + 1}-vm-username-${var.env}")
  value        = "crimeportal${count.index + 1}_${random_string.vm_username.result}"
  key_vault_id = data.azurerm_key_vault.crime_portal_vault.id
}

resource "azurerm_key_vault_secret" "vm_password_secret" {
  count        = local.vm_count
  name         = lower("crime-portal-vm${count.index + 1}-vm-password-${var.env}")
  value        = random_password.vm_password[count.index].result
  key_vault_id = data.azurerm_key_vault.crime_portal_vault.id
}

data "azurerm_backup_policy_vm" "policy" {
  name                = var.azurerm_backup_policy_vm_name
  recovery_vault_name = var.azurerm_recovery_services_vault_name
  resource_group_name = var.resource_group
}
resource "random_string" "username" {
  for_each = merge(var.frontend_vms, var.ldap_vms)
  length   = 4
  special  = false
}

resource "random_password" "password" {
  for_each         = merge(var.frontend_vms, var.ldap_vms)
  length           = 16
  special          = true
  override_special = "#$%&@()_[]{}<>:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

resource "azurerm_key_vault_secret" "username_secret" {
  for_each     = merge(var.frontend_vms, var.ldap_vms)
  name         = "${each.key}-vm-username-${var.env}"
  value        = random_string.username[each.key].result
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "password_secret" {
  for_each     = merge(var.frontend_vms, var.ldap_vms)
  name         = "${each.key}-vm-password-${var.env}"
  value        = random_password.password[each.key].result
  key_vault_id = data.azurerm_key_vault.vault.id
}
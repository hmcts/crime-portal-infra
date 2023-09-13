resource "azurerm_role_assignment" "ldap_rbac" {
  for_each             = { for value in local.flattened_ldap_users : "${value.user_key}-${value.vm_key}" => value }
  scope                = each.value.vm_id
  role_definition_name = each.value.user.role_type == "admin" ? "Virtual Machine Administrator Login" : "Virtual Machine User Login"
  principal_id         = each.value.user.is_user == true ? data.azuread_user.ldap_users[each.value.user_key].id : each.value.user.is_group == true ? data.azuread_group.ldap_groups[each.value.user_key].id : data.azuread_service_principal.ldap_sps[each.value.user_key].id
}

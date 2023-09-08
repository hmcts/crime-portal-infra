module "virtual_machine" {
  for_each = var.ldap_vms

  source = "git::https://github.com/hmcts/terraform-module-virtual-machine.git?ref=master"

  providers = {
    azurerm     = azurerm
    azurerm.soc = azurerm.soc
    azurerm.cnp = azurerm.cnp
  }

  env                  = var.env
  vm_type              = "linux"
  vm_name              = each.key
  vm_resource_group    = local.resource_group_name
  vm_admin_password    = "example-super-secure-password"
  vm_subnet_id         = data.azurerm_subnet.backend.id
  vm_publisher_name    = "canonical"
  vm_offer             = "0001-com-ubuntu-server-jammy"
  vm_sku               = "22_04-lts-gen2"
  vm_size              = "Standard_D2ds_v5"
  vm_version           = "latest"
  vm_availabilty_zones = each.value.availability_zone
  tags                 = module.ctags.common_tags
}

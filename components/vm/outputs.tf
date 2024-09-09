output "XDR_TAGS" {
  value = { for vm in local.virtual_machines : vm.key => module.virtual-machines[each.key].xdr_tags if vm.install_xdr_agent || vm.install_xdr_collector }
}

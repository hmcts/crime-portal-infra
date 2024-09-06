output "XDR_TAGS" {
  value = { for vm in module.virtual-machines : vm.vm_id => vm.xdr_tags }
}

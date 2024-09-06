output "XDR_TAGS" {
  value = { for vm in module.virtual-machines : vm.vm_id => vm_id.xdr_tags }
}

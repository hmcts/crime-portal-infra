module "core-infra" {
  source      = "git::https://github.com/hmcts/terraform-module-dlrm-core-infra.git?ref=feat%2Fsupport-multiple-subnets-to-single-nsg"
  env         = var.env
  project     = var.product
  common_tags = module.ctags.common_tags

  subnets                 = var.subnets
  route_tables            = var.route_tables
  network_security_groups = var.network_security_groups
}

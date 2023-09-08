module "core-infra" {
  source      = "git::https://github.com/hmcts/terraform-module-dlrm-core-infra.git?ref=main"
  env         = var.env
  project     = "crime-portal"
  common_tags = module.ctags.common_tags
}

module "postgresql" {
  providers = {
    azurerm.postgres_network = azurerm
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=fix%2Fsimplify-permission-script"

  env                 = var.env
  product             = var.product
  component           = "backend"
  business_area       = "dlrm"
  name                = var.env == "stg" ? "crime-portal-backend01" : ""
  resource_group_name = local.resource_group_name

  pgsql_databases               = var.postgres_databases
  pgsql_version                 = var.pgsql_version
  pgsql_delegated_subnet_id     = data.azurerm_subnet.backend-postgresql.id
  admin_user_object_id          = data.azurerm_client_config.current.object_id
  enable_read_only_group_access = false

  common_tags = module.ctags.common_tags
}

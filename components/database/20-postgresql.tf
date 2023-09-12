module "postgresql" {
  providers = {
    azurerm.postgres_network = azurerm
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=fix%2Fset-db-permissions-script-ado-fix"

  env                 = var.env
  product             = var.product
  component           = "backend"
  business_area       = "dlrm"
  resource_group_name = local.resource_group_name

  pgsql_databases           = var.postgres_databases
  pgsql_version             = var.pgsql_version
  pgsql_delegated_subnet_id = data.azurerm_subnet.backend-postgresql.id
  admin_user_object_id      = "7ef3b6ce-3974-41ab-8512-c3ef4bb8ae01"

  common_tags = module.ctags.common_tags
}

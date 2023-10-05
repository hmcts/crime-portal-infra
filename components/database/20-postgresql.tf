module "postgresql" {
  providers = {
    azurerm.postgres_network = azurerm
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=fix%2Fsimplify-permission-script"

  env                 = var.env
  product             = var.product
  component           = "backend"
  business_area       = "dlrm"
  name                = "crime-portal-postgresql"
  resource_group_name = local.resource_group_name

  pgsql_databases               = var.postgres_databases
  pgsql_version                 = var.pgsql_version
  pgsql_delegated_subnet_id     = data.azurerm_subnet.backend-postgresql.id
  admin_user_object_id          = data.azurerm_client_config.current.object_id
  enable_read_only_group_access = false

  pgsql_server_configuration = [
    {
      name  = "azure.extensions"
      value = "LO,PGCRYPTO,TABLEFUNC"
    },
    {
      name  = "backslash_quote"
      value = "on"
    }
  ]

  common_tags = module.ctags.common_tags
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "db_admin" {
  server_name         = "crime-portal-postgresql-${var.env}"
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id
  principal_name      = data.azuread_group.db_admin.display_name
  principal_type      = "Group"

  depends_on = [module.postgresql]
}

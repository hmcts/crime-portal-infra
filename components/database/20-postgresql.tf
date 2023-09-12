module "postgresql" {
  providers = {
    azurerm.postgres_network = azurerm
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=master"

  env                 = var.env
  product             = var.product
  component           = "backend"
  business_area       = "dlrm"
  resource_group_name = local.resource_group_name

  pgsql_databases           = var.postgres_databases
  pgsql_version             = var.pgsql_version
  pgsql_delegated_subnet_id = data.azurerm_subnet.backend-postgresql.id
  admin_user_object_id      = "ca6d5085-485a-417d-8480-c3cefa29df31"

  common_tags = module.ctags.common_tags
}

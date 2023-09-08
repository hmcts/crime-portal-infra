module "postgresql" {

  providers = {
    azurerm.postgres_network = azurerm
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=master"
  env    = var.env

  product       = var.product
  component     = "backend"
  business_area = "dlrm"

  pgsql_databases = [
    {
      name : "application"
    }
  ]

  pgsql_version = "14"

  pgsql_delegated_subnet_id = data.azurerm_subnet.backend.id
  admin_user_object_id      = data.azurerm_client_config.current.object_id

  common_tags = module.ctags.common_tags
}

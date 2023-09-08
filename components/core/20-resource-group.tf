resource "azurerm_resource_group" "this" {
  name     = "crime-portal-${var.env}-rg"
  location = var.location
  tags     = module.ctags.common_tags
}

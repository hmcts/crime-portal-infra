variable "location" {
  type        = string
  description = "The Azure region to deploy resources to."
  default     = "uksouth"
}

locals {
  vm_size       = "Standard_D4ds_v5"
  ipconfig_name = "IP_CONFIGURATION"

  vm_subnet_id = data.azurerm_subnet.frontend.id

  vm_availability_zones = [1, 2]

  vm_count            = 2
  resource_group_name = "crime-portal-rg-${var.env}"
}

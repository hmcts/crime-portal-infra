terraform {
  required_version = "1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.88.0"
    }
  }

  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "acme"
  subscription_id = var.acme_subscription_id
  features        {}
}
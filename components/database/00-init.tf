terraform {
  required_version = "1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.43.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

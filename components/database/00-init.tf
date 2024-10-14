terraform {
  required_version = "1.7.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

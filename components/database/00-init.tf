terraform {
  required_version = "1.9.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.97.1"
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

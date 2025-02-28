terraform {
  required_version = "1.7.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.117.1"
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
  subscription_id = var.subscription_id
}

provider "azuread" {}

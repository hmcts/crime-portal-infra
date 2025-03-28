terraform {
  required_version = "1.7.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

terraform {
  required_version = "1.12.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.22.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

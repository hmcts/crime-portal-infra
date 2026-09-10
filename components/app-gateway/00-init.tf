terraform {
  required_version = ">= 1.7.5, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.5.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

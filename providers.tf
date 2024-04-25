terraform {

  required_providers {
    random = {
      source = "hashicorp/random"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.95.0"
    }

  }

}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
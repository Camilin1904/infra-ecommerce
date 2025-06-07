terraform {
  backend "azurerm" {

    storage_account_name = "tfstate1749162202"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
  }
}

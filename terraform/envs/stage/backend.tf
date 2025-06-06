terraform {
  backend "azurerm" {
    # These values will be provided during terraform init via -backend-config parameters
    # or can be set directly here for manual deployments

    storage_account_name = "tfstate1749162202"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    # key will be different for each environment: dev/terraform.tfstate, stage/terraform.tfstate, prod/terraform.tfstate
  }
}

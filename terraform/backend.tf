terraform {
  backend "azurerm" {
    # These values will be provided during terraform init via -backend-config parameters
    # or can be set directly here for manual deployments
    
    # storage_account_name = "terraformstatestorage"
    # container_name       = "tfstate"
    # resource_group_name  = "rg-terraform-state"
    # key                  = "dev/terraform.tfstate"  # This will be different for each environment
  }
}

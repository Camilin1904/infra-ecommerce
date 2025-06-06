# Outputs for Terraform Backend Infrastructure

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.terraform_state.name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.terraform_state.id
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.terraform_state.primary_access_key
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = azurerm_storage_account.terraform_state.primary_blob_endpoint
}

output "resource_group_name" {
  description = "Name of the resource group containing the backend resources"
  value       = azurerm_resource_group.terraform_state.name
}

output "resource_group_id" {
  description = "ID of the resource group containing the backend resources"
  value       = azurerm_resource_group.terraform_state.id
}

output "container_name" {
  description = "Name of the storage container for state files"
  value       = azurerm_storage_container.terraform_state.name
}

output "location" {
  description = "Azure region where the backend resources are located"
  value       = azurerm_resource_group.terraform_state.location
}

# Backend configuration outputs for easy reference
output "backend_config" {
  description = "Backend configuration for terraform init"
  value = {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
  }
}

output "backend_config_dev" {
  description = "Backend configuration for development environment"
  value = {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    key                = "dev/terraform.tfstate"
  }
}

output "backend_config_stage" {
  description = "Backend configuration for staging environment"
  value = {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    key                = "stage/terraform.tfstate"
  }
}

output "backend_config_prod" {
  description = "Backend configuration for production environment"
  value = {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    key                = "prod/terraform.tfstate"
  }
}

# Instructions for using the backend
output "usage_instructions" {
  description = "Instructions for using the created backend"
  value = <<-EOT
    Backend created successfully!
    
    To use this backend in your Terraform configurations:
    
    1. Add this to your terraform block:
       terraform {
         backend "azurerm" {
           storage_account_name = "${azurerm_storage_account.terraform_state.name}"
           container_name      = "${azurerm_storage_container.terraform_state.name}"
           resource_group_name = "${azurerm_resource_group.terraform_state.name}"
           key                = "your-environment/terraform.tfstate"
         }
       }
    
    2. Initialize Terraform:
       terraform init
    
    Available state file keys:
    - dev/terraform.tfstate
    - stage/terraform.tfstate  
    - prod/terraform.tfstate
  EOT
}

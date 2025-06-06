# Terraform Backend Configuration
# Generated automatically by backend infrastructure deployment

# Backend Details
Storage Account Name: ${storage_account_name}
Container Name: ${container_name}
Resource Group Name: ${resource_group_name}
Location: ${location}

# Environment-specific backend configurations:

## Development Environment
terraform init -backend-config="storage_account_name=${storage_account_name}" \
              -backend-config="container_name=${container_name}" \
              -backend-config="resource_group_name=${resource_group_name}" \
              -backend-config="key=dev/terraform.tfstate"

## Staging Environment  
terraform init -backend-config="storage_account_name=${storage_account_name}" \
              -backend-config="container_name=${container_name}" \
              -backend-config="resource_group_name=${resource_group_name}" \
              -backend-config="key=stage/terraform.tfstate"

## Production Environment
terraform init -backend-config="storage_account_name=${storage_account_name}" \
              -backend-config="container_name=${container_name}" \
              -backend-config="resource_group_name=${resource_group_name}" \
              -backend-config="key=prod/terraform.tfstate"

# Backend Block for terraform {} configuration:
terraform {
  backend "azurerm" {
    storage_account_name = "${storage_account_name}"
    container_name      = "${container_name}"
    resource_group_name = "${resource_group_name}"
    # key will vary by environment
  }
}

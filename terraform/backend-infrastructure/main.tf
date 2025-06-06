# Terraform Backend Infrastructure
# This file creates the Azure resources needed for Terraform remote state storage
# Run this BEFORE setting up the main infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Generate random suffix for storage account name (must be globally unique)
resource "random_integer" "storage_suffix" {
  min = 1000000000
  max = 9999999999
}

# Resource Group for Terraform state storage
resource "azurerm_resource_group" "terraform_state" {
  name     = var.state_resource_group_name
  location = var.location

  tags = {
    Environment = "terraform-backend"
    Purpose     = "terraform-state-storage"
    Project     = var.project_name
    ManagedBy   = "terraform"
    CreatedDate = timestamp()
  }
}

# Storage Account for Terraform state
resource "azurerm_storage_account" "terraform_state" {
  name                     = "${var.state_storage_account_prefix}${random_integer.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                 = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  
  # Security configurations
  enable_https_traffic_only      = true
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  # Versioning and soft delete for state file protection
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
    
    delete_retention_policy {
      days = var.state_retention_days
    }
    
    container_delete_retention_policy {
      days = var.state_retention_days
    }
  }

  tags = {
    Environment = "terraform-backend"
    Purpose     = "terraform-state-storage"
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Storage Container for Terraform state files
resource "azurerm_storage_container" "terraform_state" {
  name                  = var.state_container_name
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}

# Optional: Storage Management Policy for cost optimization
resource "azurerm_storage_management_policy" "terraform_state" {
  storage_account_id = azurerm_storage_account.terraform_state.id

  rule {
    name    = "terraform-state-lifecycle"
    enabled = true
    
    filters {
      prefix_match = [var.state_container_name]
      blob_types   = ["blockBlob"]
    }
    
    actions {
      base_blob {
        # Move to cool storage after 30 days
        tier_to_cool_after_days_since_modification_greater_than = 30
        # Move to archive after 90 days
        tier_to_archive_after_days_since_modification_greater_than = 90
      }
      
      version {
        # Delete old versions after retention period
        delete_after_days_since_creation = var.state_retention_days
      }
    }
  }
}

# Optional: Role assignment for additional security
resource "azurerm_role_assignment" "terraform_state_contributor" {
  count                = length(var.terraform_state_contributors)
  scope                = azurerm_storage_account.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.terraform_state_contributors[count.index]
}

# Output backend configuration for easy reference
resource "local_file" "backend_config" {
  filename = "${path.root}/backend-config.txt"
  content = templatefile("${path.module}/templates/backend-config.txt.tpl", {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    location           = azurerm_resource_group.terraform_state.location
  })
}

# Generate backend configuration for different environments
resource "local_file" "backend_dev" {
  filename = "${path.root}/backend-configs/backend-dev.hcl"
  content = templatefile("${path.module}/templates/backend-env.hcl.tpl", {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    key                = "dev/terraform.tfstate"
  })
}

resource "local_file" "backend_stage" {
  filename = "${path.root}/backend-configs/backend-stage.hcl"
  content = templatefile("${path.module}/templates/backend-env.hcl.tpl", {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    key                = "stage/terraform.tfstate"
  })
}

resource "local_file" "backend_prod" {
  filename = "${path.root}/backend-configs/backend-prod.hcl"
  content = templatefile("${path.module}/templates/backend-env.hcl.tpl", {
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name      = azurerm_storage_container.terraform_state.name
    resource_group_name = azurerm_resource_group.terraform_state.name
    key                = "prod/terraform.tfstate"
  })
}

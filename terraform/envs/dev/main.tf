terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  
  backend "azurerm" {
    storage_account_name = "tfstate1749162202"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    key                  = "dev/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Data source to reference existing resource group (when not creating new one)
data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.existing_resource_group_name
}

# Conditionally create resource group
module "resource_group" {
  count  = var.create_resource_group ? 1 : 0
  source = "../../modules/resource_group"
  
  name     = "rg-ecommerce-dev"
  location = var.resource_group_location
  tags = {
    Environment = "dev"
    Project     = "ecommerce"
    Owner       = "development-team"
    CreatedBy   = "terraform"
  }
}

# Local values to handle resource group reference
locals {
  resource_group_name = var.create_resource_group ? module.resource_group[0].name : data.azurerm_resource_group.existing[0].name
  resource_group_location = var.create_resource_group ? module.resource_group[0].location : data.azurerm_resource_group.existing[0].location
}

module "aks_cluster" {
  source = "../../modules/cluster"
  
  cluster_name        = "aks-ecommerce-dev"
  location           = local.resource_group_location
  resource_group_name = local.resource_group_name
  dns_prefix         = "aks-ecommerce-dev"

  
  # Default node pool configuration
  node_count         = 2
  vm_size           = "Standard_D2s_v3"
  enable_auto_scaling = true
  min_node_count     = 1
  max_node_count     = 5
  
  # Network configuration for development
  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.0.0.0/16"
  dns_service_ip = "10.0.0.10"
  
  # Monitoring and logging
  enable_log_analytics = true
  log_retention_days  = 30
  
  # Development-specific settings
  enable_azure_policy = false
  enable_http_application_routing = false
  
  # Maintenance window (Sunday early morning)
  maintenance_window = {
    day   = "Sunday"
    hours = [2, 3]
  }
  
  tags = {
    Environment = "dev"
    Project     = "ecommerce"
    Owner       = "development-team"
    CreatedBy   = "terraform"
    Workload    = "kubernetes"
  }
}

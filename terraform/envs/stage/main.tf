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
    key                  = "stage/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Conditionally create resource group
module "resource_group" {
  count  = var.create_resource_group ? 1 : 0
  source = "../../modules/resource_group"
  
  name     = "rg-ecommerce-stage"
  location = var.resource_group_location
  tags = {
    Environment = "stage"
    Project     = "ecommerce"
    Owner       = "staging-team"
    CreatedBy   = "terraform"
  }
}

# Local values to handle resource group reference
locals {
  resource_group_name = module.resource_group[0].name
  resource_group_location = module.resource_group[0].location
}

module "aks_cluster" {
  source = "../../modules/cluster"
  
  cluster_name        = "aks-ecommerce-stage"
  location           = local.resource_group_location
  resource_group_name = local.resource_group_name
  dns_prefix         = "aks-ecommerce-stage"

  
  # Staging node pool configuration - slightly more robust than dev
  node_count         = 3
  vm_size           = "Standard_D4s_v3"
  enable_auto_scaling = true
  min_node_count     = 2
  max_node_count     = 8
  
  # Network configuration for staging
  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.1.0.0/16"
  dns_service_ip = "10.1.0.10"
  
  # Monitoring and logging
  enable_log_analytics = true
  log_retention_days  = 60
  
  # Staging-specific settings
  enable_azure_policy = true
  enable_http_application_routing = false
  
  # Maintenance window (Saturday early morning)
  maintenance_window = {
    day   = "Saturday"
    hours = [3, 4]
  }
  
  tags = {
    Environment = "stage"
    Project     = "ecommerce"
    Owner       = "staging-team"
    CreatedBy   = "terraform"
    Workload    = "kubernetes"
  }
}

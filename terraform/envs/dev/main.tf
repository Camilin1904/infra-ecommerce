terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true # Recommended for CI/CD
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
  resource_group_name     = module.resource_group[0].name
  resource_group_location = module.resource_group[0].location
}

module "aks_cluster" {
  source = "../../modules/cluster"

  cluster_name        = "aks-ecommerce-dev"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  dns_prefix          = "aks-ecommerce-dev"


  node_count          = 2
  vm_size             = "Standard_D2s_v3"
  enable_auto_scaling = true
  min_node_count      = 1
  max_node_count      = 5

  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.0.0.0/16"
  dns_service_ip = "10.0.0.10"

  enable_log_analytics = true
  log_retention_days   = 30

  enable_azure_policy             = false
  enable_http_application_routing = false

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

data "azurerm_container_registry" "my_acr" {
  name                = "ecommerceRegistry" 
  resource_group_name = "rg-container-state"   
}

resource "azurerm_role_assignment" "aks_acr_pull_permission" {
  scope                = data.azurerm_container_registry.my_acr.id
  role_definition_name = "AcrPull" 
  principal_id         = module.aks_cluster.cluster_id
}


terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  
  backend "azurerm" {
    storage_account_name = "tfstate1749154418"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    key                  = "prod/terraform.tfstate"
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
  
  name     = "rg-ecommerce-prod"
  location = var.resource_group_location
  tags = {
    Environment = "production"
    Project     = "ecommerce"
    Owner       = "production-team"
    CreatedBy   = "terraform"
    CriticalLevel = "high"
  }
}

# Local values to handle resource group reference
locals {
  resource_group_name = var.create_resource_group ? module.resource_group[0].name : data.azurerm_resource_group.existing[0].name
  resource_group_location = var.create_resource_group ? module.resource_group[0].location : data.azurerm_resource_group.existing[0].location
}

module "aks_cluster" {
  source = "../../modules/cluster"
  
  cluster_name        = "aks-ecommerce-prod"
  location           = local.resource_group_location
  resource_group_name = local.resource_group_name
  dns_prefix         = "aks-ecommerce-prod"
  kubernetes_version  = "1.27.3"

  
  # Production node pool configuration - high availability
  node_count         = 5
  vm_size           = "Standard_D8s_v3"
  enable_auto_scaling = true
  min_node_count     = 3
  max_node_count     = 20
  
  # Network configuration for production
  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.2.0.0/16"
  dns_service_ip = "10.2.0.10"
  
  # Monitoring and logging - extended retention for production
  enable_log_analytics = true
  log_retention_days  = 90
  
  # Production-specific settings - enhanced security
  enable_azure_policy = true
  enable_http_application_routing = false
  
  # Additional node pools for production workloads
  additional_node_pools = {
    "compute" = {
      vm_size             = "Standard_D16s_v3"
      node_count          = 3
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 10
      os_disk_size_gb     = 100
      os_disk_type        = "Managed"
      node_labels = {
        "workload-type" = "compute-intensive"
        "environment"   = "production"
      }
      node_taints = []
      tags = {
        "NodePool" = "compute"
        "Environment" = "production"
      }
    }
  }
  
  # Maintenance window (Sunday very early morning)
  maintenance_window = {
    day   = "Sunday"
    hours = [1, 2]
  }
  
  tags = {
    Environment = "production"
    Project     = "ecommerce"
    Owner       = "production-team"
    CreatedBy   = "terraform"
    Workload    = "kubernetes"
    CriticalLevel = "high"
    BackupRequired = "true"
  }
}

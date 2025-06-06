terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Create Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Default node pool
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size

    # Enable auto-scaling
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null

    # Network configuration
    vnet_subnet_id = var.subnet_id

    # Node configuration
    os_disk_size_gb = var.os_disk_size_gb
    os_disk_type    = var.os_disk_type

    tags = var.tags
  }

  # Service Principal or Managed Identity
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    pod_cidr          = var.network_plugin == "kubenet" ? var.pod_cidr : null
  }

  # Addon profiles
  oms_agent {
    log_analytics_workspace_id = var.enable_log_analytics ? azurerm_log_analytics_workspace.aks.id : null
  }

  azure_policy_enabled = var.enable_azure_policy

  http_application_routing_enabled = var.enable_http_application_routing

  # RBAC
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Maintenance window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      allowed {
        day   = maintenance_window.value.day
        hours = maintenance_window.value.hours
      }
    }
  }

  tags = var.tags

  depends_on = [azurerm_log_analytics_workspace.aks]
}

# Additional node pool (optional)
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count

  # Auto-scaling
  enable_auto_scaling = each.value.enable_auto_scaling
  min_count           = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count           = each.value.enable_auto_scaling ? each.value.max_count : null

  # Node configuration
  os_disk_size_gb = each.value.os_disk_size_gb
  os_disk_type    = each.value.os_disk_type
  vnet_subnet_id  = var.subnet_id

  # Node labels and taints
  node_labels = each.value.node_labels
  node_taints = each.value.node_taints

  tags = merge(var.tags, each.value.tags)
}

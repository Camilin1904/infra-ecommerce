# Azure Kubernetes Service (AKS) Cluster Module

This module creates an Azure Kubernetes Service (AKS) cluster with configurable node pools, networking, monitoring, and security features.

## Features

- 🚀 **Production-ready AKS cluster** with best practices
- 🔧 **Auto-scaling** support for node pools
- 📊 **Log Analytics integration** for monitoring
- 🔐 **Azure AD integration** for RBAC
- 🌐 **Advanced networking** with Azure CNI or Kubenet
- 🔄 **Additional node pools** support
- 🛡️ **Azure Policy** integration (optional)
- 📈 **Comprehensive monitoring** and logging

## Usage

### Basic Usage

```hcl
module "aks_cluster" {
  source = "./modules/cluster"
  
  cluster_name        = "aks-ecommerce-dev"
  location           = "East US"
  resource_group_name = "rg-ecommerce-dev"
  dns_prefix         = "aks-ecommerce-dev"
  
  tags = {
    Environment = "dev"
    Project     = "ecommerce"
  }
}
```

### Advanced Usage with Custom Node Pools

```hcl
module "aks_cluster" {
  source = "./modules/cluster"
  
  cluster_name        = "aks-ecommerce-prod"
  location           = "East US"
  resource_group_name = "rg-ecommerce-prod"
  dns_prefix         = "aks-ecommerce-prod"
  kubernetes_version  = "1.27.3"
  
  # Default node pool
  node_count         = 3
  vm_size           = "Standard_D4s_v3"
  enable_auto_scaling = true
  min_node_count     = 2
  max_node_count     = 10
  
  # Network configuration
  network_plugin = "azure"
  network_policy = "azure"
  service_cidr   = "10.0.0.0/16"
  dns_service_ip = "10.0.0.10"
  
  # Additional node pools
  additional_node_pools = {
    "compute" = {
      vm_size             = "Standard_D8s_v3"
      node_count          = 2
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      os_disk_size_gb     = 100
      os_disk_type        = "Managed"
      node_labels = {
        "workload-type" = "compute-intensive"
      }
      node_taints = []
      tags = {
        "NodePool" = "compute"
      }
    }
  }
  
  # Security and RBAC
  admin_group_object_ids = ["your-azure-ad-group-id"]
  
  # Monitoring
  enable_log_analytics = true
  log_retention_days  = 30
  
  # Add-ons
  enable_azure_policy = true
  
  # Maintenance window
  maintenance_window = {
    day   = "Sunday"
    hours = [2, 3, 4]
  }
  
  tags = {
    Environment = "production"
    Project     = "ecommerce"
    Owner       = "platform-team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_log_analytics_workspace.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | The name of the AKS cluster | `string` | n/a | yes |
| location | The Azure region where the AKS cluster will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group where the AKS cluster will be created | `string` | n/a | yes |
| dns_prefix | DNS prefix for the AKS cluster | `string` | `null` | no |
| kubernetes_version | Version of Kubernetes to use for the AKS cluster | `string` | `null` | no |
| node_count | The number of nodes in the default node pool | `number` | `3` | no |
| vm_size | The size of the Virtual Machine | `string` | `"Standard_D2s_v3"` | no |
| enable_auto_scaling | Enable auto scaling for the default node pool | `bool` | `true` | no |
| min_node_count | The minimum number of nodes for auto-scaling | `number` | `1` | no |
| max_node_count | The maximum number of nodes for auto-scaling | `number` | `10` | no |
| network_plugin | Network plugin to use for networking | `string` | `"azure"` | no |
| network_policy | Network policy to use for networking | `string` | `"azure"` | no |
| enable_log_analytics | Enable Log Analytics monitoring for AKS | `bool` | `true` | no |
| admin_group_object_ids | A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster | `list(string)` | `[]` | no |
| additional_node_pools | Additional node pools for the AKS cluster | `map(object)` | `{}` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the AKS cluster |
| cluster_name | The name of the AKS cluster |
| cluster_fqdn | The FQDN of the AKS cluster |
| kube_config | Raw Kubernetes config (sensitive) |
| node_resource_group | The name of the Resource Group containing the VMSS |
| identity_principal_id | The Principal ID of the System Assigned Managed Identity |
| log_analytics_workspace_id | The ID of the Log Analytics Workspace |

## Post-Deployment Steps

After deploying the AKS cluster, you can connect to it using:

```bash
# Get AKS credentials
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>

# Verify connection
kubectl get nodes
```

## Security Considerations

- The cluster uses System Assigned Managed Identity for authentication
- Azure AD integration is enabled for RBAC
- Network policies are enforced for pod-to-pod communication
- Log Analytics is enabled for monitoring and auditing

## Cost Optimization

- Auto-scaling is enabled by default to optimize costs
- Consider using spot instances for non-critical workloads
- Use appropriate VM sizes for your workload requirements
- Monitor resource usage through Azure Monitor

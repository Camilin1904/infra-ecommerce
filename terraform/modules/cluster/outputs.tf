output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_config_host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "kube_config_username" {
  description = "The Kubernetes cluster username"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.username
  sensitive   = true
}

output "kube_config_password" {
  description = "The Kubernetes cluster password"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.password
  sensitive   = true
}

output "kube_config_client_certificate" {
  description = "The Kubernetes cluster client certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "kube_config_client_key" {
  description = "The Kubernetes cluster client key"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

output "kube_config_cluster_ca_certificate" {
  description = "The Kubernetes cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "node_resource_group" {
  description = "The name of the Resource Group containing the Virtual Machine Scale Sets and other resources"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity"
  value       = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}

output "identity_tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity"
  value       = azurerm_kubernetes_cluster.aks.identity.0.tenant_id
}

output "kubelet_identity_object_id" {
  description = "The Object ID of the user-defined Managed Identity assigned to the Kubelets"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

output "kubelet_identity_client_id" {
  description = "The Client ID of the user-defined Managed Identity assigned to the Kubelets"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0.client_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.aks.id : null
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.aks.name : null
}

output "additional_node_pools" {
  description = "Information about additional node pools"
  value = {
    for k, v in azurerm_kubernetes_cluster_node_pool.additional : k => {
      id   = v.id
      name = v.name
    }
  }
}

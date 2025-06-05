output "resource_group_id" {
  description = "The ID of the resource group"
  value       = var.create_resource_group ? module.resource_group[0].id : data.azurerm_resource_group.existing[0].id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = local.resource_group_location
}

output "resource_group_created" {
  description = "Whether the resource group was created by this configuration"
  value       = var.create_resource_group
}

# AKS Cluster outputs
output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks_cluster.cluster_id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks_cluster.cluster_name
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks_cluster.cluster_fqdn
}

output "aks_node_resource_group" {
  description = "The resource group containing AKS nodes"
  value       = module.aks_cluster.node_resource_group
}

output "aks_identity_principal_id" {
  description = "The Principal ID of the AKS managed identity"
  value       = module.aks_cluster.identity_principal_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = module.aks_cluster.log_analytics_workspace_id
}

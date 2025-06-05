variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 63
    error_message = "Cluster name must be between 1 and 63 characters."
  }
}

variable "location" {
  description = "The Azure region where the AKS cluster will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the AKS cluster will be created"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use for the AKS cluster"
  type        = string
  default     = null
}

# Node pool configuration
variable "node_count" {
  description = "The number of nodes in the default node pool"
  type        = number
  default     = 3
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 100
    error_message = "Node count must be between 1 and 100."
  }
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the default node pool"
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "The minimum number of nodes for auto-scaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "The maximum number of nodes for auto-scaling"
  type        = number
  default     = 10
}

variable "os_disk_size_gb" {
  description = "The size of the OS Disk in GB"
  type        = number
  default     = 30
}

variable "os_disk_type" {
  description = "The type of disk for the OS"
  type        = string
  default     = "Managed"
  validation {
    condition     = contains(["Managed", "Ephemeral"], var.os_disk_type)
    error_message = "OS disk type must be either 'Managed' or 'Ephemeral'."
  }
}

# Network configuration
variable "subnet_id" {
  description = "The ID of the subnet where the AKS cluster will be deployed"
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "Network plugin to use for networking"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy to use for networking"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either 'azure' or 'calico'."
  }
}

variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery"
  type        = string
  default     = "10.0.0.10"
}

variable "pod_cidr" {
  description = "The CIDR to use for pod IP addresses"
  type        = string
  default     = "10.244.0.0/16"
}

# Monitoring and logging
variable "enable_log_analytics" {
  description = "Enable Log Analytics monitoring for AKS"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "The workspace data retention in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

# Add-ons
variable "enable_azure_policy" {
  description = "Enable Azure Policy add-on"
  type        = bool
  default     = false
}

variable "enable_http_application_routing" {
  description = "Enable HTTP Application Routing add-on"
  type        = bool
  default     = false
}

# RBAC
variable "admin_group_object_ids" {
  description = "A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster"
  type        = list(string)
  default     = []
}

# Maintenance
variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day   = string
    hours = list(number)
  })
  default = null
}

# Additional node pools
variable "additional_node_pools" {
  description = "Additional node pools for the AKS cluster"
  type = map(object({
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    os_disk_type        = string
    node_labels         = map(string)
    node_taints         = list(string)
    tags                = map(string)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# Variables for Terraform Backend Infrastructure

variable "location" {
  description = "The Azure region where backend resources will be created"
  type        = string
  default     = "East US"
}

variable "state_resource_group_name" {
  description = "Name of the resource group for Terraform state storage"
  type        = string
  default     = "rg-terraform-state"
}

variable "state_storage_account_prefix" {
  description = "Prefix for the storage account name (will be suffixed with random numbers)"
  type        = string
  default     = "tfstate"
  
  validation {
    condition     = length(var.state_storage_account_prefix) <= 14
    error_message = "Storage account prefix must be 14 characters or less to allow for random suffix."
  }
}

variable "state_container_name" {
  description = "Name of the storage container for Terraform state files"
  type        = string
  default     = "tfstate"
}

variable "storage_replication_type" {
  description = "Type of replication for the storage account"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "state_retention_days" {
  description = "Number of days to retain deleted state files and versions"
  type        = number
  default     = 30
  
  validation {
    condition     = var.state_retention_days >= 1 && var.state_retention_days <= 365
    error_message = "State retention days must be between 1 and 365."
  }
}

variable "project_name" {
  description = "Name of the project for tagging purposes"
  type        = string
  default     = "ecommerce-infrastructure"
}

variable "terraform_state_contributors" {
  description = "List of principal IDs that should have contributor access to the Terraform state storage"
  type        = list(string)
  default     = []
}

variable "enable_versioning" {
  description = "Enable versioning on the storage account for state file protection"
  type        = bool
  default     = true
}

variable "enable_soft_delete" {
  description = "Enable soft delete for blob storage protection"
  type        = bool
  default     = true
}

variable "environment_keys" {
  description = "Map of environment names to their state file keys"
  type        = map(string)
  default = {
    dev   = "dev/terraform.tfstate"
    stage = "stage/terraform.tfstate"
    prod  = "prod/terraform.tfstate"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

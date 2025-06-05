variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one"
  type        = bool
  default     = true
}

variable "existing_resource_group_name" {
  description = "Name of existing resource group (used when create_resource_group is false)"
  type        = string
  default     = ""
  validation {
    condition = var.create_resource_group == true || (var.create_resource_group == false && length(var.existing_resource_group_name) > 0)
    error_message = "When create_resource_group is false, existing_resource_group_name must be provided."
  }
}

variable "resource_group_location" {
  description = "Location for the resource group (only used when creating new resource group)"
  type        = string
  default     = "East US"
}

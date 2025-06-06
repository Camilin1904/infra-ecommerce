variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one"
  type        = bool
  default     = true
}


variable "resource_group_location" {
  description = "Location for the resource group (only used when creating new resource group)"
  type        = string
  default     = "East US"
}

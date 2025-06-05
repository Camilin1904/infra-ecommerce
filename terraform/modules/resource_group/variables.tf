variable "name" {
  description = "The name of the resource group"
  type        = string
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "The Azure region where the resource group will be created"
  type        = string
  default     = "East US"
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East", "Brazil South", "North Europe",
      "West Europe", "UK South", "UK West", "France Central", "Germany West Central",
      "Switzerland North", "Norway East", "Sweden Central", "Australia East",
      "Australia Southeast", "East Asia", "Southeast Asia", "Japan East",
      "Japan West", "Korea Central", "India Central", "UAE North",
      "South Africa North"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}

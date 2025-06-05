# Azure Resource Group Module

This module creates an Azure Resource Group with configurable name, location, and tags.

## Usage

```hcl
module "resource_group" {
  source = "./modules/resource_group"
  
  name     = "rg-ecommerce-dev"
  location = "East US"
  tags = {
    Environment = "dev"
    Project     = "ecommerce"
    Owner       = "team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region where the resource group will be created | `string` | `"East US"` | no |
| tags | A map of tags to assign to the resource group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource group |
| name | The name of the resource group |
| location | The location of the resource group |
| tags | The tags assigned to the resource group |

## Examples

### Basic Usage
```hcl
module "basic_rg" {
  source = "./modules/resource_group"
  name   = "rg-basic-example"
}
```

### With Custom Location and Tags
```hcl
module "tagged_rg" {
  source   = "./modules/resource_group"
  name     = "rg-tagged-example"
  location = "West Europe"
  tags = {
    Environment = "production"
    CostCenter  = "engineering"
    Owner       = "platform-team"
  }
}
```

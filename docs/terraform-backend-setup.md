# Terraform Backend Setup Guide

This guide explains how to set up and manage the Terraform backend for the e-commerce infrastructure project.

## 🏗️ Backend Infrastructure

The Terraform backend is already set up and configured with the following Azure resources:

### Created Resources
- **Resource Group**: `rg-terraform-state`
- **Storage Account**: `tfstate1749154418`
- **Container**: `tfstate`
- **Location**: `East US`

### State Files Organization
```
tfstate container/
├── dev/terraform.tfstate       # Development environment state
├── stage/terraform.tfstate     # Staging environment state
└── prod/terraform.tfstate      # Production environment state
```

## 🚀 Quick Start

### 1. Backend is Already Configured
The backend has been automatically configured in all environment files:
- `terraform/envs/dev/main.tf`
- `terraform/envs/stage/main.tf`
- `terraform/envs/prod/main.tf`

### 2. Initialize Any Environment
```bash
cd terraform/envs/dev
terraform init
```

### 3. Verify Backend Configuration
```bash
terraform show
# Should show that state is stored remotely
```

## 🔧 Manual Backend Configuration

If you need to reconfigure or set up the backend from scratch:

### Option 1: Run the Setup Script
```bash
./scripts/setup-terraform-backend.sh
```

### Option 2: Manual Azure CLI Commands
```bash
# Set variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"
CONTAINER_NAME="tfstate"
LOCATION="East US"

# Create resource group
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION"

# Create storage account
az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku "Standard_LRS" \
    --kind "StorageV2" \
    --allow-blob-public-access false

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query '[0].value' -o tsv)

# Create container
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$ACCOUNT_KEY"
```

## 🔐 Security Features

The backend storage account includes:
- ✅ **Public access disabled** - No anonymous access to blobs
- ✅ **TLS 1.2 minimum** - Secure transport encryption
- ✅ **Standard LRS** - Local redundant storage for cost optimization
- ✅ **Access via Azure credentials** - Authenticated access only

## 📝 Azure DevOps Integration

The pipeline variables are already configured in:
- `azure-pipelines.yml`
- `azure-pipelines-destroy.yml`

### Pipeline Variables:
```yaml
TERRAFORM_BACKEND_STORAGE_ACCOUNT: 'tfstate1749154418'
TERRAFORM_BACKEND_CONTAINER: 'tfstate'
TERRAFORM_BACKEND_RESOURCE_GROUP: 'rg-terraform-state'
```

## 🔄 State Management Commands

### View Current State
```bash
terraform state list
```

### Import Existing Resources
```bash
terraform import azurerm_resource_group.example /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}
```

### Move State Resources
```bash
terraform state mv 'azurerm_resource_group.old' 'azurerm_resource_group.new'
```

### Remove Resources from State
```bash
terraform state rm 'azurerm_resource_group.example'
```

## 🚨 Troubleshooting

### Issue: Backend Configuration Not Found
**Solution**: Ensure the backend block is present in your Terraform configuration:
```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "tfstate1749154418"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    key                  = "environment/terraform.tfstate"
  }
}
```

### Issue: Authentication Errors
**Solution**: Ensure you're logged in to Azure CLI:
```bash
az login
az account show
```

### Issue: Storage Account Access Denied
**Solution**: Verify your Azure account has Contributor access to the storage account:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv) --scope /subscriptions/{subscription-id}/resourceGroups/rg-terraform-state
```

### Issue: State Lock Conflicts
**Solution**: If state is locked, you can force unlock (use with caution):
```bash
terraform force-unlock <lock-id>
```

## 🔒 Backend Configuration per Environment

### Development Environment
```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "tfstate1749154418"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    key                  = "dev/terraform.tfstate"
  }
}
```

### Staging Environment
```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "tfstate1749154418"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    key                  = "stage/terraform.tfstate"
  }
}
```

### Production Environment
```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "tfstate1749154418"
    container_name       = "tfstate"
    resource_group_name  = "rg-terraform-state"
    key                  = "prod/terraform.tfstate"
  }
}
```

## 💡 Best Practices

1. **Never edit state files manually** - Always use Terraform commands
2. **Use state locking** - Azure backend automatically provides state locking
3. **Regular backups** - Azure Storage provides built-in redundancy
4. **Access control** - Use Azure RBAC to control who can access state files
5. **Environment isolation** - Each environment has its own state file
6. **Monitor access** - Enable Azure Storage analytics for audit logging

## 📊 Cost Optimization

The current backend setup uses:
- **Standard LRS storage** - Lowest cost option
- **Pay-as-you-go** - No upfront costs
- **Minimal storage** - State files are typically small

Estimated monthly cost: **< $1 USD** for typical usage.

## 🔄 Migration from Local State

If you have existing local state files, migrate them:

```bash
# 1. Add backend configuration to your .tf files
# 2. Initialize with migration
terraform init -migrate-state

# 3. Confirm the migration when prompted
# 4. Verify state is now remote
terraform state list
```

## 📞 Support

For issues with the backend setup:
1. Check the troubleshooting section above
2. Review Azure Storage account permissions
3. Verify network connectivity to Azure
4. Check Terraform version compatibility

---

**Backend Status**: ✅ Configured and Ready
**Last Updated**: June 5, 2025
**Storage Account**: tfstate1749154418

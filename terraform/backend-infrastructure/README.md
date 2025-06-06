# Terraform Backend Infrastructure

This directory contains Terraform configuration to create and manage the Azure resources required for Terraform remote state storage.

## 🏗️ What This Creates

- **Resource Group**: Container for backend resources
- **Storage Account**: Secure blob storage for Terraform state files  
- **Storage Container**: Container for organizing state files
- **Management Policy**: Lifecycle management for cost optimization
- **Security Configuration**: HTTPS-only, versioning, soft delete

## 📋 Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.0 installed
- Sufficient Azure permissions to create resources

## 🚀 Quick Start

### 1. Prepare Configuration

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables as needed
vi terraform.tfvars
```

### 2. Deploy Backend Infrastructure

```bash
# Initialize Terraform (no backend needed for this bootstrap)
terraform init

# Review planned changes
terraform plan

# Deploy the backend infrastructure
terraform apply
```

### 3. Use the Created Backend

After deployment, you'll get output showing how to configure your main Terraform projects:

```bash
# The outputs will show you the backend configuration
terraform output usage_instructions
```

## 📁 Generated Files

After running `terraform apply`, several files are generated:

- `backend-config.txt` - Complete backend configuration reference
- `backend-configs/backend-dev.hcl` - Dev environment backend config
- `backend-configs/backend-stage.hcl` - Stage environment backend config  
- `backend-configs/backend-prod.hcl` - Prod environment backend config

## 🔄 Using Generated Configs

### Option 1: Backend Config Files

```bash
# Initialize with environment-specific config
terraform init -backend-config=backend-configs/backend-dev.hcl
```

### Option 2: Direct Backend Block

Add to your main Terraform configuration:

```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "tfstate1234567890"  # From output
    container_name      = "tfstate"
    resource_group_name = "rg-terraform-state"
    key                = "dev/terraform.tfstate"  # Per environment
  }
}
```

## 🔧 Configuration Options

### Storage Replication

| Type | Description | Cost | Durability |
|------|-------------|------|------------|
| LRS | Locally redundant | Lowest | 11 9's |
| GRS | Geo-redundant | Medium | 16 9's |
| ZRS | Zone redundant | Medium | 12 9's |

### State File Organization

```
tfstate container/
├── dev/terraform.tfstate      # Development
├── stage/terraform.tfstate    # Staging  
├── prod/terraform.tfstate     # Production
└── feature-*/terraform.tfstate # Feature branches
```

## 🛡️ Security Features

- **HTTPS Only**: All traffic encrypted in transit
- **Private Access**: Container access set to private
- **Versioning**: Automatic versioning of state files
- **Soft Delete**: Protection against accidental deletion
- **Access Control**: RBAC for storage access

## 💰 Cost Optimization

- **Lifecycle Management**: Automatic tier transition
  - Cool storage after 30 days
  - Archive storage after 90 days
- **Version Cleanup**: Old versions deleted after retention period
- **Monitoring**: Cost alerts recommended

## 🔍 Monitoring & Maintenance

### Check Backend Health

```bash
# Verify storage account access
az storage account show --name tfstate1234567890 --resource-group rg-terraform-state

# List state files
az storage blob list --account-name tfstate1234567890 --container-name tfstate
```

### Backup State Files

```bash
# Download current state for backup
az storage blob download \
  --account-name tfstate1234567890 \
  --container-name tfstate \
  --name dev/terraform.tfstate \
  --file backup-dev-$(date +%Y%m%d).tfstate
```

## 🚨 Important Notes

### State File Management

- **Never edit state files directly**
- **Always use `terraform import` for existing resources**
- **Keep backups of critical state files**
- **Use state locking in team environments**

### Security Considerations

- **Limit access** to the storage account
- **Enable Azure Monitor** for access logging
- **Use service principals** for CI/CD pipelines
- **Rotate access keys** regularly

### Disaster Recovery

- Enable geo-redundant storage (GRS) for production
- Document state file recovery procedures  
- Test backup and restore processes
- Consider cross-region replication for critical environments

## 🛠️ Troubleshooting

### Common Issues

#### Backend Initialization Fails
```bash
# Check Azure authentication
az account show

# Verify storage account exists
az storage account show --name tfstate1234567890 --resource-group rg-terraform-state
```

#### Access Denied Errors
```bash
# Check permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --scope /subscriptions/$(az account show --query id -o tsv)
```

#### State Lock Issues
```bash
# Force unlock if needed (use carefully!)
terraform force-unlock LOCK_ID
```

## 📞 Support

For issues with the backend infrastructure:

1. Check Azure portal for resource status
2. Review Terraform output and logs  
3. Verify Azure CLI authentication
4. Check subscription limits and quotas

## 🔄 Updates

To update the backend infrastructure:

1. Modify variables in `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to update resources
4. Update any generated config files as needed

**⚠️ Warning**: Changes to storage account name will require state migration!

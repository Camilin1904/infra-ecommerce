# 🚀 Azure DevOps Setup Guide

## Overview
This guide will help you set up your Azure DevOps project to run the Terraform pipelines for your e-commerce infrastructure across dev, stage, and prod environments.

## Prerequisites ✅
- Azure subscription with sufficient permissions
- Azure DevOps organization
- Terraform backend already configured (✅ **DONE**)
- Azure CLI authenticated (✅ **DONE**)

## 🏗️ Step 1: Create Azure DevOps Project

1. Navigate to your Azure DevOps organization: `https://dev.azure.com/{your-organization}`
2. Click **"+ New project"**
3. Configure project:
   - **Project name**: `infra-ecommerce`
   - **Description**: `Infrastructure as Code for E-commerce Platform`
   - **Visibility**: Private
   - **Version control**: Git
   - **Work item process**: Agile

## 🔗 Step 2: Create Service Connection

1. In your Azure DevOps project, go to **Project Settings** (bottom left)
2. Under **Pipelines**, select **Service connections**
3. Click **"Create service connection"**
4. Select **"Azure Resource Manager"** → **Next**
5. Choose **"Service principal (automatic)"** → **Next**
6. Configure connection:
   - **Scope level**: Subscription
   - **Subscription**: Select your Azure subscription
   - **Resource group**: Leave empty (subscription scope)
   - **Service connection name**: `azure-service-connection`
   - **Description**: `Service connection for Terraform deployments`
   - **Grant access permission to all pipelines**: ✅ Check this
7. Click **Save**

## 📁 Step 3: Import Repository

### Option A: Clone from existing repo
If you have the code in a Git repository:
1. Go to **Repos** → **Files**
2. Click **"Import a repository"**
3. Enter your repository URL
4. Click **Import**

### Option B: Push local code
If working locally:
```bash
cd /home/camilin/Documents/Icesi/ingesoft/infra-ecommerce

# Initialize git if not already done
git init
git add .
git commit -m "Initial infrastructure setup"

# Add Azure DevOps remote
git remote add origin https://dev.azure.com/{your-organization}/infra-ecommerce/_git/infra-ecommerce

# Push to Azure DevOps
git push -u origin main
```

## ⚙️ Step 4: Create Pipeline Variables

1. Go to **Pipelines** → **Library**
2. Click **"+ Variable group"**
3. Create variable group: `terraform-backend`

### Required Variables:
| Variable Name | Value | Secret |
|---------------|--------|--------|
| `TERRAFORM_BACKEND_STORAGE_ACCOUNT` | `tfstate1749154418` | No |
| `TERRAFORM_BACKEND_CONTAINER` | `tfstate` | No |
| `TERRAFORM_BACKEND_RESOURCE_GROUP` | `rg-terraform-state` | No |
| `AZURE_SERVICE_CONNECTION` | `azure-service-connection` | No |

4. Click **Save**

## 🎯 Step 5: Create Environments

1. Go to **Pipelines** → **Environments**
2. Create three environments:

### Development Environment
- **Name**: `development`
- **Description**: `Development environment for testing`
- **Approvers**: None (automatic deployment)

### Staging Environment
- **Name**: `staging`
- **Description**: `Staging environment for pre-production testing`
- **Approvers**: Add team leads or senior developers
- **Required approvals**: 1

### Production Environment
- **Name**: `production`
- **Description**: `Production environment`
- **Approvers**: Add deployment managers and senior team members
- **Required approvals**: 2
- **Additional settings**:
  - Enable **"Restrict deployments to specific times"** if needed
  - Consider adding **"Required deployment history"** checks

## 🚦 Step 6: Set Up Pipelines

### Main Deployment Pipeline
1. Go to **Pipelines** → **Pipelines**
2. Click **"Create Pipeline"**
3. Select **"Azure Repos Git"**
4. Choose your repository
5. Select **"Existing Azure Pipelines YAML file"**
6. Select path: `/azure-pipelines.yml`
7. Click **Continue** → **Save**

### Destroy Pipeline (Optional but Recommended)
1. Click **"New pipeline"**
2. Follow same steps but select path: `/azure-pipelines-destroy.yml`
3. Rename pipeline to: `Infrastructure Destroy`

## 🔒 Step 7: Configure Branch Policies (Recommended)

1. Go to **Repos** → **Branches**
2. Click the **three dots** next to `main` branch
3. Select **Branch policies**
4. Configure:
   - **Require a minimum number of reviewers**: 1
   - **Check for linked work items**: Optional
   - **Build validation**: Add your pipeline as required
   - **Automatically included reviewers**: Add team members

## 📊 Step 8: Test Your Setup

### Initial Pipeline Run
1. Go to **Pipelines** → **Pipelines**
2. Select your main pipeline
3. Click **"Run pipeline"**
4. Select:
   - **Branch**: `main`
   - **Advanced options** → **Variables**:
     - `SKIP_DESTROY`: `true` (for safety)
5. Click **Run**

### Expected Flow:
1. **Build and Validate** stage runs automatically
2. **Development** deployment runs automatically
3. **Staging** deployment waits for approval
4. **Production** deployment waits for approval (after staging)

## 🛠️ Step 9: Environment-Specific Configuration

Create these files for each environment if they don't exist:

### Development (`terraform/envs/dev/terraform.tfvars`)
```hcl
# AKS Configuration
cluster_name = "aks-ecommerce-dev"
node_count = 2
node_size = "Standard_D2s_v3"

# Networking
service_cidr = "10.0.0.0/16"
dns_service_ip = "10.0.0.10"

# Environment settings
environment = "dev"
```

### Staging (`terraform/envs/stage/terraform.tfvars`)
```hcl
# AKS Configuration
cluster_name = "aks-ecommerce-stage"
node_count = 3
node_size = "Standard_D4s_v3"

# Networking
service_cidr = "10.1.0.0/16"
dns_service_ip = "10.1.0.10"

# Environment settings
environment = "stage"
```

### Production (`terraform/envs/prod/terraform.tfvars`)
```hcl
# AKS Configuration
cluster_name = "aks-ecommerce-prod"
node_count = 5
node_size = "Standard_D8s_v3"

# Networking
service_cidr = "10.2.0.0/16"
dns_service_ip = "10.2.0.10"

# Environment settings
environment = "prod"
```

## 🔍 Troubleshooting

### Common Issues:

#### 1. Service Connection Authentication
If you get authentication errors:
```bash
# Check Azure CLI login
az account show

# Re-authenticate if needed
az login
```

#### 2. Pipeline Permissions
If pipeline fails with permission errors:
- Go to **Project Settings** → **Service connections**
- Edit your service connection
- Ensure **"Grant access permission to all pipelines"** is checked

#### 3. State File Access
If Terraform state errors occur:
```bash
# Verify backend access
cd terraform/envs/dev
terraform init
```

## 📈 Monitoring and Maintenance

### Pipeline Monitoring
1. Enable **Pipeline notifications** in project settings
2. Set up **Azure Monitor** alerts for resource usage
3. Regular review of deployment logs

### Security Best Practices
1. Regularly rotate service principal credentials
2. Review approval groups quarterly
3. Monitor resource costs using Azure Cost Management

## 🎯 Next Steps

1. **Create Azure DevOps project** ← **START HERE**
2. **Set up service connection**
3. **Import/push your code**
4. **Configure environments**
5. **Run first deployment**
6. **Set up monitoring**

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Azure DevOps pipeline logs
3. Verify Terraform backend connectivity
4. Check Azure resource permissions

---

**🎉 Your infrastructure is ready for deployment! Follow this guide step by step, and you'll have a fully functional CI/CD pipeline for your e-commerce platform.**

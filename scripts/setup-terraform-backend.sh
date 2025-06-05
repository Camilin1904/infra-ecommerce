#!/bin/bash

# Script to create Azure storage account for Terraform state management
# Run this once before setting up the CI/CD pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"  # Append timestamp for uniqueness
CONTAINER_NAME="tfstate"
LOCATION="East US"

echo -e "${BLUE}🚀 Setting up Terraform Backend Infrastructure...${NC}"
echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Resource Group: $RESOURCE_GROUP_NAME"
echo "  Storage Account: $STORAGE_ACCOUNT_NAME"
echo "  Container: $CONTAINER_NAME"
echo "  Location: $LOCATION"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Error: Azure CLI is not installed${NC}"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Running 'az login'...${NC}"
    az login
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
echo -e "${BLUE}📋 Using subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)${NC}"

# Create resource group
echo -e "${GREEN}📁 Creating resource group...${NC}"
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --tags \
        purpose="terraform-state" \
        environment="shared" \
        created-by="setup-script"

# Create storage account
echo -e "${GREEN}💾 Creating storage account...${NC}"
az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku "Standard_LRS" \
    --kind "StorageV2" \
    --allow-blob-public-access false \
    --min-tls-version "TLS1_2" \
    --tags \
        purpose="terraform-state" \
        environment="shared"

# Get storage account key
echo -e "${GREEN}🔑 Getting storage account key...${NC}"
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query '[0].value' -o tsv)

# Create blob container
echo -e "${GREEN}📦 Creating blob container...${NC}"
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$ACCOUNT_KEY" \
    --public-access off

echo -e "${GREEN}✅ Terraform backend infrastructure created successfully!${NC}"
echo ""
echo -e "${BLUE}📝 Backend Configuration:${NC}"
echo -e "${YELLOW}storage_account_name = \"$STORAGE_ACCOUNT_NAME\"${NC}"
echo -e "${YELLOW}container_name       = \"$CONTAINER_NAME\"${NC}"
echo -e "${YELLOW}resource_group_name  = \"$RESOURCE_GROUP_NAME\"${NC}"
echo ""
echo -e "${BLUE}🔧 Update your Azure DevOps pipeline variables:${NC}"
echo "  TERRAFORM_BACKEND_STORAGE_ACCOUNT: $STORAGE_ACCOUNT_NAME"
echo "  TERRAFORM_BACKEND_CONTAINER: $CONTAINER_NAME"
echo "  TERRAFORM_BACKEND_RESOURCE_GROUP: $RESOURCE_GROUP_NAME"
echo ""
echo -e "${BLUE}💡 To use this backend in your Terraform configurations:${NC}"
echo ""
echo "terraform {"
echo "  backend \"azurerm\" {"
echo "    storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo "    resource_group_name  = \"$RESOURCE_GROUP_NAME\""
echo "    key                  = \"<environment>/terraform.tfstate\""
echo "  }"
echo "}"
echo ""
echo -e "${GREEN}🎉 Setup completed! You can now run your Terraform configurations with remote state.${NC}"

# Create a backend configuration file for easy reference
cat > backend-config.txt << EOF
# Terraform Backend Configuration
# Use these values in your terraform init command or update your pipeline variables

TERRAFORM_BACKEND_STORAGE_ACCOUNT=$STORAGE_ACCOUNT_NAME
TERRAFORM_BACKEND_CONTAINER=$CONTAINER_NAME
TERRAFORM_BACKEND_RESOURCE_GROUP=$RESOURCE_GROUP_NAME

# Example usage:
# terraform init \\
#   -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \\
#   -backend-config="container_name=$CONTAINER_NAME" \\
#   -backend-config="resource_group_name=$RESOURCE_GROUP_NAME" \\
#   -backend-config="key=dev/terraform.tfstate"
EOF

echo -e "${BLUE}📄 Backend configuration saved to: backend-config.txt${NC}"

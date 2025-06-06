#!/bin/bash

# Import Existing Backend Resources
# This script imports your existing backend infrastructure into Terraform management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Import Existing Backend Infrastructure${NC}"
echo "========================================="

# Configuration - matches your existing setup
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="tfstate1749154418"
CONTAINER_NAME="tfstate"

echo -e "${YELLOW}Importing existing resources:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT" 
echo "Container: $CONTAINER_NAME"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! az account show >/dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure${NC}"
    echo "Please run: az login"
    exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
    echo -e "${RED}❌ Terraform is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Verify resources exist
echo -e "${YELLOW}Verifying existing resources...${NC}"

if ! az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo -e "${RED}❌ Resource group $RESOURCE_GROUP not found${NC}"
    exit 1
fi

if ! az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo -e "${RED}❌ Storage account $STORAGE_ACCOUNT not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Existing resources verified${NC}"

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Update terraform.tfvars with exact storage account name
echo -e "${BLUE}Updating configuration for existing resources...${NC}"

# Create a custom random_integer resource for the existing suffix
cat > import_random.tf << EOF
# Temporary resource to import existing random suffix
resource "random_integer" "existing_storage_suffix" {
  min = 1749154418
  max = 1749154418
}
EOF

# Import random integer first
echo -e "${BLUE}Importing random suffix...${NC}"
terraform import random_integer.storage_suffix 1749154418 || true

# Remove temporary file
rm -f import_random.tf

# Import resource group
echo -e "${BLUE}Importing resource group...${NC}"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
RG_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
terraform import azurerm_resource_group.terraform_state "$RG_ID"

# Import storage account  
echo -e "${BLUE}Importing storage account...${NC}"
STORAGE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
terraform import azurerm_storage_account.terraform_state "$STORAGE_ID"

# Import storage container
echo -e "${BLUE}Importing storage container...${NC}"
terraform import azurerm_storage_container.terraform_state "https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER_NAME"

# Import management policy if it exists
echo -e "${BLUE}Checking for management policy...${NC}"
if az storage account management-policy show --account-name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo -e "${YELLOW}Importing storage management policy...${NC}"
    terraform import azurerm_storage_management_policy.terraform_state "$STORAGE_ID/default" || echo -e "${YELLOW}⚠️  Management policy import failed (may not exist)${NC}"
else
    echo -e "${YELLOW}⚠️  No management policy found${NC}"
fi

# Run terraform plan to check state
echo -e "${BLUE}Checking imported state...${NC}"
terraform plan

echo ""
echo -e "${GREEN}🎉 Backend infrastructure import completed!${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Review the terraform plan output above"
echo "2. Run 'terraform apply' if changes are needed"
echo "3. Your existing backend is now managed by Terraform"
echo ""
echo -e "${YELLOW}⚠️  Important Notes:${NC}"
echo "- Your existing state files are preserved"
echo "- No changes were made to existing resources"
echo "- You can now manage the backend infrastructure with Terraform"

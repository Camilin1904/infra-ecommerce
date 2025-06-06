#!/bin/bash

# Quick validation script for Terraform backend
# This script verifies that your backend is properly configured and accessible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Terraform Backend Validation${NC}"
echo "=================================="

# Backend configuration from backend-config.txt
STORAGE_ACCOUNT="tfstate1749154418"
CONTAINER="tfstate"
RESOURCE_GROUP="rg-terraform-state"

echo -e "${BLUE}📋 Checking backend configuration...${NC}"

# Check if Azure CLI is available
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure${NC}"
    echo -e "${YELLOW}💡 Run: az login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI authenticated${NC}"

# Check resource group
if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${GREEN}✅ Resource group '$RESOURCE_GROUP' exists${NC}"
else
    echo -e "${RED}❌ Resource group '$RESOURCE_GROUP' not found${NC}"
    exit 1
fi

# Check storage account
if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${GREEN}✅ Storage account '$STORAGE_ACCOUNT' exists${NC}"
else
    echo -e "${RED}❌ Storage account '$STORAGE_ACCOUNT' not found${NC}"
    exit 1
fi

# Check container
ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --query '[0].value' -o tsv 2>/dev/null)
if az storage container show --name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" &> /dev/null; then
    echo -e "${GREEN}✅ Container '$CONTAINER' exists${NC}"
else
    echo -e "${RED}❌ Container '$CONTAINER' not found${NC}"
    exit 1
fi

echo -e "${BLUE}🔧 Testing Terraform environments...${NC}"

# Test each environment
ENVIRONMENTS=("dev" "stage" "prod")
for env in "${ENVIRONMENTS[@]}"; do
    ENV_PATH="terraform/envs/$env"
    if [ -d "$ENV_PATH" ]; then
        echo -e "${BLUE}  Testing $env environment...${NC}"
        cd "$ENV_PATH"
        
        # Check if terraform init works
        if terraform init -backend=false &> /dev/null; then
            echo -e "${GREEN}    ✅ $env configuration valid${NC}"
        else
            echo -e "${RED}    ❌ $env configuration invalid${NC}"
        fi
        
        cd - > /dev/null
    else
        echo -e "${RED}    ❌ $env environment directory not found${NC}"
    fi
done

echo -e "${BLUE}📊 Backend storage status...${NC}"

# List blobs in container
BLOB_COUNT=$(az storage blob list --container-name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" --query "length(@)" -o tsv 2>/dev/null || echo "0")
echo -e "${BLUE}   State files in storage: $BLOB_COUNT${NC}"

if [ "$BLOB_COUNT" -gt 0 ]; then
    echo -e "${BLUE}   Existing state files:${NC}"
    az storage blob list --container-name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" --query "[].name" -o tsv 2>/dev/null | sed 's/^/     /'
fi

echo ""
echo -e "${GREEN}🎉 Backend Validation Complete!${NC}"
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "   1. cd terraform/envs/dev && terraform init"
echo "   2. terraform plan"
echo "   3. terraform apply"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "   - BACKEND-STATUS.md    (Quick overview)"
echo "   - docs/terraform-backend-setup.md    (Detailed guide)"

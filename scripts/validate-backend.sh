#!/bin/bash

# Script to validate Terraform backend setup across all environments
# Usage: ./scripts/validate-backend.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Validating Terraform Backend Setup...${NC}"
echo ""

# Check if Azure CLI is available and logged in
echo -e "${BLUE}🔐 Checking Azure authentication...${NC}"
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    exit 1
fi

if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI authenticated${NC}"

# Backend configuration
STORAGE_ACCOUNT="tfstate1749154418"
CONTAINER="tfstate"
RESOURCE_GROUP="rg-terraform-state"

# Check if backend resources exist
echo -e "${BLUE}🏗️  Checking backend infrastructure...${NC}"

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
ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --query '[0].value' -o tsv)
if az storage container show --name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" &> /dev/null; then
    echo -e "${GREEN}✅ Container '$CONTAINER' exists${NC}"
else
    echo -e "${RED}❌ Container '$CONTAINER' not found${NC}"
    exit 1
fi

# Check Terraform configurations
echo -e "${BLUE}📝 Checking Terraform configurations...${NC}"

ENVIRONMENTS=("dev" "stage" "prod")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

for env in "${ENVIRONMENTS[@]}"; do
    ENV_PATH="$PROJECT_ROOT/terraform/envs/$env"
    
    if [ -d "$ENV_PATH" ]; then
        echo -e "${BLUE}  Checking $env environment...${NC}"
        
        # Check if main.tf exists
        if [ -f "$ENV_PATH/main.tf" ]; then
            # Check if backend configuration is present
            if grep -q "backend \"azurerm\"" "$ENV_PATH/main.tf"; then
                # Validate Terraform configuration
                cd "$ENV_PATH"
                if terraform validate &> /dev/null; then
                    echo -e "${GREEN}    ✅ $env configuration is valid${NC}"
                else
                    echo -e "${RED}    ❌ $env configuration has validation errors${NC}"
                fi
            else
                echo -e "${RED}    ❌ $env missing backend configuration${NC}"
            fi
        else
            echo -e "${RED}    ❌ $env main.tf not found${NC}"
        fi
    else
        echo -e "${RED}    ❌ $env environment directory not found${NC}"
    fi
done

# Test backend connectivity
echo -e "${BLUE}🔗 Testing backend connectivity...${NC}"
cd "$PROJECT_ROOT/terraform/envs/dev"

# Try to initialize (this will test backend connectivity)
if terraform init -input=false &> /dev/null; then
    echo -e "${GREEN}✅ Backend connectivity successful${NC}"
    
    # Check if state file exists
    if az storage blob exists \
        --container-name "$CONTAINER" \
        --name "dev/terraform.tfstate" \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$ACCOUNT_KEY" \
        --output tsv 2>/dev/null | grep -q "True"; then
        echo -e "${GREEN}✅ State file exists in backend${NC}"
    else
        echo -e "${YELLOW}⚠️  No state file found (this is normal for new deployments)${NC}"
    fi
else
    echo -e "${RED}❌ Backend connectivity failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Backend validation completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Backend Summary:${NC}"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Environments: dev, stage, prod"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "  1. Create terraform.tfvars files for each environment"
echo "  2. Run 'terraform plan' to preview infrastructure changes"
echo "  3. Run 'terraform apply' to deploy infrastructure"
echo "  4. Set up Azure DevOps pipeline with the backend configuration"

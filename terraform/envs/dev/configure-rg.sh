#!/bin/bash

# Script to quickly configure resource group options for AKS deployment
# Usage: ./configure-rg.sh [new|existing] [resource-group-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 new [location]                    # Create new resource group (default: East US)"
    echo "  $0 existing <resource-group-name>    # Use existing resource group"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 new                              # Create new RG in East US"
    echo "  $0 new \"West Europe\"               # Create new RG in West Europe"
    echo "  $0 existing rg-ecommerce-shared     # Use existing RG"
}

if [ $# -lt 1 ]; then
    echo -e "${RED}❌ Error: Missing arguments${NC}"
    show_usage
    exit 1
fi

MODE=$1

case $MODE in
    "new")
        LOCATION=${2:-"East US"}
        echo -e "${GREEN}🚀 Configuring for NEW resource group...${NC}"
        echo -e "${YELLOW}📍 Location: $LOCATION${NC}"
        
        cat > terraform.tfvars << EOF
# Resource Group Configuration - Create new resource group
create_resource_group = true
resource_group_location = "$LOCATION"

# AKS Cluster will be created in the new resource group
# Add additional configuration as needed
EOF

        echo -e "${GREEN}✅ Created terraform.tfvars for new resource group${NC}"
        echo -e "${BLUE}💡 Next steps:${NC}"
        echo "  terraform init"
        echo "  terraform plan"
        echo "  terraform apply"
        ;;
        
    "existing")
        if [ $# -lt 2 ]; then
            echo -e "${RED}❌ Error: Resource group name required for existing mode${NC}"
            show_usage
            exit 1
        fi
        
        RG_NAME=$2
        echo -e "${GREEN}🔗 Configuring for EXISTING resource group...${NC}"
        echo -e "${YELLOW}📋 Resource Group: $RG_NAME${NC}"
        
        # Check if resource group exists
        echo -e "${BLUE}🔍 Checking if resource group exists...${NC}"
        if command -v az &> /dev/null; then
            if az group show --name "$RG_NAME" &> /dev/null; then
                echo -e "${GREEN}✅ Resource group '$RG_NAME' found${NC}"
                RG_LOCATION=$(az group show --name "$RG_NAME" --query location -o tsv)
                echo -e "${BLUE}📍 Location: $RG_LOCATION${NC}"
            else
                echo -e "${YELLOW}⚠️  Warning: Resource group '$RG_NAME' not found${NC}"
                echo -e "${YELLOW}   Make sure it exists before running terraform apply${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Azure CLI not found - skipping resource group validation${NC}"
        fi
        
        cat > terraform.tfvars << EOF
# Resource Group Configuration - Use existing resource group
create_resource_group = false
existing_resource_group_name = "$RG_NAME"

# AKS Cluster will be created in the existing resource group
# Add additional configuration as needed
EOF

        echo -e "${GREEN}✅ Created terraform.tfvars for existing resource group${NC}"
        echo -e "${BLUE}💡 Next steps:${NC}"
        echo "  terraform init"
        echo "  terraform plan"
        echo "  terraform apply"
        ;;
        
    *)
        echo -e "${RED}❌ Error: Invalid mode '$MODE'${NC}"
        show_usage
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📝 Current terraform.tfvars content:${NC}"
echo -e "${YELLOW}$(cat terraform.tfvars)${NC}"

#!/bin/bash

# Deploy Terraform Backend Infrastructure
# This script creates the Azure resources needed for Terraform remote state storage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🏗️  Terraform Backend Infrastructure Deployment${NC}"
echo "================================================="

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check if Azure CLI is installed and authenticated
if ! command -v az >/dev/null 2>&1; then
    echo -e "${RED}❌ Azure CLI is not installed${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show >/dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Azure${NC}"
    echo "Please run: az login"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform >/dev/null 2>&1; then
    echo -e "${RED}❌ Terraform is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Show current Azure context
echo ""
echo -e "${BLUE}Current Azure Context:${NC}"
echo "Subscription: $(az account show --query name -o tsv)"
echo "Account: $(az account show --query user.name -o tsv)"
echo ""

# Confirm deployment
read -p "Continue with backend infrastructure deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Create terraform.tfvars if it doesn't exist
if [ ! -f terraform.tfvars ]; then
    echo -e "${YELLOW}Creating terraform.tfvars from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}⚠️  Please review and customize terraform.tfvars before proceeding${NC}"
    read -p "Press Enter to continue after reviewing terraform.tfvars..."
fi

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Validate configuration
echo -e "${BLUE}Validating Terraform configuration...${NC}"
terraform validate

# Plan deployment
echo -e "${BLUE}Planning deployment...${NC}"
terraform plan -out=tfplan

# Confirm deployment
echo ""
read -p "Apply the above plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    rm -f tfplan
    exit 0
fi

# Apply deployment
echo -e "${BLUE}Deploying backend infrastructure...${NC}"
terraform apply tfplan

# Clean up plan file
rm -f tfplan

# Show outputs
echo ""
echo -e "${GREEN}🎉 Backend infrastructure deployed successfully!${NC}"
echo ""
echo -e "${BLUE}Backend Configuration:${NC}"
terraform output backend_config

echo ""
echo -e "${BLUE}Usage Instructions:${NC}"
terraform output -raw usage_instructions

echo ""
echo -e "${YELLOW}📁 Generated Files:${NC}"
echo "- backend-config.txt (backend configuration reference)"
echo "- backend-configs/ (environment-specific configs)"
echo ""

echo -e "${GREEN}✅ Backend infrastructure is ready for use!${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Update your main Terraform configurations to use this backend"
echo "2. Run 'terraform init' in your environment directories"
echo "3. Migrate existing state if needed"

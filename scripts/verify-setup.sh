#!/bin/bash

# Pre-Deployment Verification Script for Azure DevOps Setup

echo "🔍 Infrastructure Readiness Check"
echo "================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_azure_cli() {
    echo -n "Checking Azure CLI authentication... "
    if az account show >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Authenticated${NC}"
        echo "   Subscription: $(az account show --query name -o tsv)"
        return 0
    else
        echo -e "${RED}❌ Not authenticated${NC}"
        echo "   Run: az login"
        return 1
    fi
}

check_terraform() {
    echo -n "Checking Terraform installation... "
    if command -v terraform >/dev/null 2>&1; then
        version=$(terraform version | head -n1 | cut -d' ' -f2)
        echo -e "${GREEN}✅ Installed (${version})${NC}"
        return 0
    else
        echo -e "${RED}❌ Not installed${NC}"
        return 1
    fi
}

check_backend() {
    echo -n "Checking Terraform backend access... "
    storage_account="tfstate1749154418"
    if az storage account show --name "$storage_account" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Accessible${NC}"
        echo "   Storage Account: $storage_account"
        return 0
    else
        echo -e "${RED}❌ Not accessible${NC}"
        return 1
    fi
}

check_terraform_init() {
    local env=$1
    echo -n "Checking Terraform init for $env... "
    
    if [ -d "terraform/envs/$env" ]; then
        cd "terraform/envs/$env"
        if terraform init >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Initialized${NC}"
            cd - >/dev/null
            return 0
        else
            echo -e "${RED}❌ Failed to initialize${NC}"
            cd - >/dev/null
            return 1
        fi
    else
        echo -e "${RED}❌ Directory not found${NC}"
        return 1
    fi
}

check_files() {
    echo "Checking required files:"
    files=(
        "azure-pipelines.yml"
        "azure-pipelines-destroy.yml"
        "terraform/envs/dev/main.tf"
        "terraform/envs/dev/terraform.tfvars"
        "terraform/envs/stage/main.tf"
        "terraform/envs/stage/terraform.tfvars"
        "terraform/envs/prod/main.tf"
        "terraform/envs/prod/terraform.tfvars"
        "docs/AZURE-DEVOPS-SETUP.md"
    )
    
    for file in "${files[@]}"; do
        echo -n "  $file... "
        if [ -f "$file" ]; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌${NC}"
        fi
    done
}

# Main execution
echo "Starting verification..."
echo ""

errors=0

# Run checks
check_azure_cli || ((errors++))
echo ""

check_terraform || ((errors++))
echo ""

check_backend || ((errors++))
echo ""

check_files
echo ""

# Test Terraform initialization for each environment
for env in dev stage prod; do
    check_terraform_init "$env" || ((errors++))
done

echo ""
echo "================================="

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Ready for Azure DevOps setup.${NC}"
    echo ""
    echo "📋 Next steps:"
    echo "1. Follow the guide in docs/AZURE-DEVOPS-SETUP.md"
    echo "2. Create your Azure DevOps project"
    echo "3. Set up the service connection"
    echo "4. Import your repository"
    echo "5. Configure pipelines"
    echo ""
    echo "🔗 Quick links:"
    echo "   - Backend status: cat BACKEND-STATUS.md"
    echo "   - Setup guide: cat docs/AZURE-DEVOPS-SETUP.md"
else
    echo -e "${RED}❌ $errors error(s) found. Please fix them before proceeding.${NC}"
    exit 1
fi

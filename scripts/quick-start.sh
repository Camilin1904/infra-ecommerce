#!/bin/bash

# Quick Start Script for Azure DevOps Pipeline Setup
# This script helps you prepare for Azure DevOps configuration

echo "🚀 Azure DevOps Quick Start Guide"
echo "================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}📋 Pre-Setup Checklist:${NC}"
echo "✅ Terraform backend configured"
echo "✅ Infrastructure code ready"
echo "✅ Pipeline files prepared"
echo "✅ Documentation complete"
echo ""

echo -e "${YELLOW}🎯 What you need to complete setup:${NC}"
echo ""
echo "1. 🏢 Azure DevOps Organization Access"
echo "   - Go to: https://dev.azure.com"
echo "   - Sign in with your Azure account"
echo ""

echo "2. 📝 Project Information (choose these values):"
echo "   - Project Name: infra-ecommerce"
echo "   - Description: Infrastructure as Code for E-commerce Platform"
echo "   - Visibility: Private"
echo ""

echo "3. 🔑 Azure Subscription Details:"
echo "   - Current subscription: $(az account show --query name -o tsv 2>/dev/null || echo 'Not logged in')"
echo "   - Subscription ID: $(az account show --query id -o tsv 2>/dev/null || echo 'Run: az login')"
echo ""

echo "4. 🔗 Service Connection Name (use this exactly):"
echo "   - Name: azure-service-connection"
echo "   - Type: Azure Resource Manager"
echo "   - Scope: Subscription"
echo ""

echo -e "${GREEN}📖 Step-by-Step Guide:${NC}"
echo "   👉 Open: docs/AZURE-DEVOPS-SETUP.md"
echo "   👉 Follow: Each step in order"
echo "   👉 Time: ~30 minutes total"
echo ""

echo -e "${BLUE}🎮 After Azure DevOps Setup:${NC}"
echo "1. Import this repository"
echo "2. Create the pipeline from azure-pipelines.yml"
echo "3. Set up environments (development, staging, production)"
echo "4. Run your first deployment"
echo ""

echo -e "${YELLOW}🛠️ Useful Commands:${NC}"
echo ""
echo "# Verify everything is ready:"
echo "./scripts/verify-setup.sh"
echo ""
echo "# Check backend status:"
echo "cat BACKEND-STATUS.md"
echo ""
echo "# Quick backend test:"
echo "./scripts/quick-backend-check.sh"
echo ""
echo "# Test Terraform locally:"
echo "cd terraform/envs/dev && terraform plan"
echo ""

echo "================================="
echo -e "${GREEN}🎯 You're ready to deploy! Follow the setup guide to go live.${NC}"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}💡 Tip: Initialize git for easier Azure DevOps import:${NC}"
    echo "git init"
    echo "git add ."
    echo "git commit -m \"Complete infrastructure setup\""
    echo ""
fi

echo "📚 Documentation:"
echo "   - Complete setup: docs/AZURE-DEVOPS-SETUP.md"
echo "   - Backend details: BACKEND-STATUS.md"
echo "   - Project overview: DEPLOYMENT-READY.md"

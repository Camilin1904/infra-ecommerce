#!/bin/bash

# Comprehensive setup script for the e-commerce infrastructure project
# This script prepares the entire project for deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="E-commerce Infrastructure"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║          🚀 $PROJECT_NAME Setup                   ║"
    echo "║                                                              ║"
    echo "║  This script will help you set up the complete Azure        ║"
    echo "║  DevOps CI/CD pipeline for Terraform infrastructure         ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    local missing_tools=()
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        missing_tools+=("Azure CLI")
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("Terraform")
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    # Check git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing required tools:${NC}"
        printf '%s\n' "${missing_tools[@]}" | sed 's/^/  - /'
        echo ""
        echo -e "${YELLOW}Please install the missing tools and run this script again.${NC}"
        echo ""
        echo -e "${BLUE}Installation guides:${NC}"
        echo "  Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        echo "  Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        echo "  kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites are installed${NC}"
}

check_azure_login() {
    echo -e "${BLUE}🔐 Checking Azure authentication...${NC}"
    
    if ! az account show &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged in to Azure. Please log in...${NC}"
        az login
    fi
    
    local subscription_name=$(az account show --query name -o tsv)
    local subscription_id=$(az account show --query id -o tsv)
    
    echo -e "${GREEN}✅ Logged in to Azure${NC}"
    echo -e "${BLUE}📋 Current subscription: $subscription_name ($subscription_id)${NC}"
    
    read -p "$(echo -e ${YELLOW}🤔 Is this the correct subscription? [y/N]: ${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}💡 Run 'az account list' to see available subscriptions${NC}"
        echo -e "${BLUE}💡 Run 'az account set --subscription <subscription-id>' to switch${NC}"
        exit 1
    fi
}

setup_terraform_backend() {
    echo -e "${BLUE}🏗️  Setting up Terraform backend infrastructure...${NC}"
    
    if [ -f "$SCRIPT_DIR/scripts/setup-terraform-backend.sh" ]; then
        chmod +x "$SCRIPT_DIR/scripts/setup-terraform-backend.sh"
        
        read -p "$(echo -e ${YELLOW}🤔 Do you want to create the Terraform backend infrastructure? [y/N]: ${NC})" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$SCRIPT_DIR"
            ./scripts/setup-terraform-backend.sh
            
            if [ -f "backend-config.txt" ]; then
                echo -e "${GREEN}✅ Backend configuration saved to backend-config.txt${NC}"
                echo -e "${YELLOW}📝 Please update your Azure DevOps pipeline variables with these values${NC}"
            fi
        else
            echo -e "${YELLOW}⏭️  Skipping backend setup. You'll need to configure this manually.${NC}"
        fi
    else
        echo -e "${RED}❌ Backend setup script not found${NC}"
    fi
}

validate_terraform_configs() {
    echo -e "${BLUE}🔍 Validating Terraform configurations...${NC}"
    
    local environments=("dev" "stage" "prod")
    local validation_failed=false
    
    for env in "${environments[@]}"; do
        local env_path="$SCRIPT_DIR/terraform/envs/$env"
        
        if [ -d "$env_path" ]; then
            echo -e "${BLUE}  Validating $env environment...${NC}"
            cd "$env_path"
            
            if terraform init -backend=false &> /dev/null && terraform validate &> /dev/null; then
                echo -e "${GREEN}    ✅ $env configuration is valid${NC}"
            else
                echo -e "${RED}    ❌ $env configuration has errors${NC}"
                validation_failed=true
            fi
        else
            echo -e "${RED}    ❌ $env environment directory not found${NC}"
            validation_failed=true
        fi
    done
    
    if [ "$validation_failed" = true ]; then
        echo -e "${RED}❌ Some Terraform configurations are invalid${NC}"
        echo -e "${YELLOW}💡 Please fix the issues and run this script again${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All Terraform configurations are valid${NC}"
}

create_tfvars_examples() {
    echo -e "${BLUE}📝 Creating terraform.tfvars examples...${NC}"
    
    local environments=("dev" "stage" "prod")
    
    for env in "${environments[@]}"; do
        local env_path="$SCRIPT_DIR/terraform/envs/$env"
        local tfvars_file="$env_path/terraform.tfvars"
        
        if [ ! -f "$tfvars_file" ]; then
            echo -e "${BLUE}  Creating terraform.tfvars for $env...${NC}"
            
            cat > "$tfvars_file" << EOF
# Terraform variables for $env environment
# Customize these values according to your requirements

# Resource Group Configuration
create_resource_group = true
resource_group_location = "East US"

# Optional: Use existing resource group
# create_resource_group = false
# existing_resource_group_name = "rg-ecommerce-shared"

# Add any additional variables specific to $env environment here
EOF
            echo -e "${GREEN}    ✅ Created terraform.tfvars for $env${NC}"
        else
            echo -e "${YELLOW}    ⏭️  terraform.tfvars already exists for $env${NC}"
        fi
    done
}

show_next_steps() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    🎉 Setup Complete!                       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo ""
    echo -e "${YELLOW}1. Azure DevOps Setup:${NC}"
    echo "   - Create a new Azure DevOps project"
    echo "   - Import this repository"
    echo "   - Create a service connection to Azure"
    echo "   - Update pipeline variables with backend configuration"
    echo ""
    echo -e "${YELLOW}2. Pipeline Configuration:${NC}"
    echo "   - Main pipeline: azure-pipelines.yml"
    echo "   - Destroy pipeline: azure-pipelines-destroy.yml"
    echo "   - Create environments in Azure DevOps: development, staging, production"
    echo ""
    echo -e "${YELLOW}3. Environment Variables to Set in Azure DevOps:${NC}"
    if [ -f "$SCRIPT_DIR/backend-config.txt" ]; then
        echo "   (Found in backend-config.txt)"
        cat "$SCRIPT_DIR/backend-config.txt" | grep "TERRAFORM_BACKEND" | sed 's/^/   /'
    else
        echo "   - TERRAFORM_BACKEND_STORAGE_ACCOUNT"
        echo "   - TERRAFORM_BACKEND_CONTAINER"
        echo "   - TERRAFORM_BACKEND_RESOURCE_GROUP"
    fi
    echo "   - AZURE_SERVICE_CONNECTION"
    echo ""
    echo -e "${YELLOW}4. Manual Deployment (Optional):${NC}"
    echo "   cd terraform/envs/dev"
    echo "   terraform init"
    echo "   terraform plan"
    echo "   terraform apply"
    echo ""
    echo -e "${YELLOW}5. Useful Commands:${NC}"
    echo "   ./scripts/setup-terraform-backend.sh  # Re-run backend setup"
    echo "   terraform fmt -recursive               # Format all .tf files"
    echo "   terraform validate                     # Validate configurations"
    echo ""
    echo -e "${GREEN}🚀 Your infrastructure is ready for deployment!${NC}"
}

# Main execution
main() {
    show_banner
    check_prerequisites
    check_azure_login
    setup_terraform_backend
    validate_terraform_configs
    create_tfvars_examples
    show_next_steps
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
#!/bin/bash

# Script to configure kubectl for the deployed AKS cluster
# Run this script after successful terraform apply

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Configuring kubectl for AKS cluster...${NC}"

# Get terraform outputs
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
CLUSTER_NAME=$(terraform output -raw aks_cluster_name)

if [ -z "$RESOURCE_GROUP" ] || [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}❌ Error: Could not get resource group or cluster name from terraform outputs${NC}"
    echo "Make sure you have run 'terraform apply' successfully"
    exit 1
fi

echo -e "${YELLOW}📋 Resource Group: $RESOURCE_GROUP${NC}"
echo -e "${YELLOW}📋 Cluster Name: $CLUSTER_NAME${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Error: Azure CLI is not installed${NC}"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ Error: kubectl is not installed${NC}"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Running 'az login'...${NC}"
    az login
fi

# Get AKS credentials
echo -e "${GREEN}🔑 Getting AKS credentials...${NC}"
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing

# Verify connection
echo -e "${GREEN}✅ Verifying cluster connection...${NC}"
kubectl cluster-info

echo -e "${GREEN}📝 Getting cluster nodes...${NC}"
kubectl get nodes

echo -e "${GREEN}🎉 Successfully configured kubectl for AKS cluster!${NC}"
echo ""
echo -e "${YELLOW}💡 Useful commands:${NC}"
echo "  kubectl get nodes                    # List cluster nodes"
echo "  kubectl get pods --all-namespaces   # List all pods"
echo "  kubectl create namespace <name>     # Create a namespace"
echo "  kubectl config get-contexts         # List available contexts"
echo ""
echo -e "${GREEN}✨ You're ready to deploy applications to your AKS cluster!${NC}"

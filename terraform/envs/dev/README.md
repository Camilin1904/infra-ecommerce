# AKS Deployment Guide

This guide will help you deploy the Azure Kubernetes Service (AKS) cluster using Terraform.

## Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   # Install Azure CLI (Ubuntu/Debian)
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Login to Azure
   az login
   ```

2. **Terraform** installed (>= 1.0)
   ```bash
   # Install Terraform
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

3. **kubectl** installed
   ```bash
   # Install kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

## Deployment Steps

### 1. Navigate to the Development Environment

```bash
cd terraform/envs/dev
```

### 2. Configure Resource Group Options

You have two options for the resource group:

#### Option A: Create a New Resource Group (Default)
```bash
# Create terraform.tfvars with default settings
cat > terraform.tfvars << EOF
create_resource_group = true
resource_group_location = "East US"
EOF
```

#### Option B: Use an Existing Resource Group
```bash
# Create terraform.tfvars to use existing resource group
cat > terraform.tfvars << EOF
create_resource_group = false
existing_resource_group_name = "rg-ecommerce-shared"
EOF
```

**When to use Option B:**
- 🔄 You're recreating the AKS cluster but want to keep the resource group
- 🏗️ You have a shared resource group for multiple environments
- 💰 You want to preserve other resources in the resource group
- 🚀 Faster deployment (skips resource group creation)

### 3. (Optional) Additional Customization

You can further customize by editing `terraform.tfvars`:

```bash
# Edit terraform.tfvars with your preferred settings
nano terraform.tfvars
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan the Deployment

```bash
terraform plan
```

Review the planned changes to ensure everything looks correct.

### 6. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

⏱️ **Expected deployment time: 10-15 minutes**

### 7. Configure kubectl

After successful deployment, run the provided script to configure kubectl:

```bash
./configure-kubectl.sh
```

This script will:
- Extract the resource group and cluster name from Terraform outputs
- Configure kubectl with AKS credentials
- Verify the cluster connection
- Show cluster nodes

### 8. Verify Deployment

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# List all system pods
kubectl get pods --all-namespaces
```

## What Gets Created

### When `create_resource_group = true` (Default)
- ✅ Azure Resource Group (`rg-ecommerce-dev`)
- ✅ AKS Cluster (`aks-ecommerce-dev`)
- ✅ Log Analytics Workspace (for monitoring)
- ✅ System-assigned Managed Identity
- ✅ Default Node Pool (auto-scaling enabled)

### When `create_resource_group = false`
- 🔗 Uses existing Azure Resource Group
- ✅ AKS Cluster (`aks-ecommerce-dev`)
- ✅ Log Analytics Workspace (for monitoring)
- ✅ System-assigned Managed Identity
- ✅ Default Node Pool (auto-scaling enabled)

## Default Configuration

| Setting | Value |
|---------|-------|
| **Cluster Name** | `aks-ecommerce-dev` |
| **Location** | `East US` |
| **Kubernetes Version** | `1.27.3` |
| **Node Count** | `2` (auto-scaling: 1-5) |
| **Node Size** | `Standard_D2s_v3` |
| **Network Plugin** | `azure` (CNI) |
| **Network Policy** | `azure` |
| **Monitoring** | Enabled (Log Analytics) |

## Post-Deployment

### Deploy a Sample Application

```bash
# Create a namespace
kubectl create namespace sample-app

# Deploy nginx
kubectl create deployment nginx --image=nginx --namespace=sample-app

# Expose the service
kubectl expose deployment nginx --port=80 --type=LoadBalancer --namespace=sample-app

# Check service status
kubectl get services --namespace=sample-app
```

### Access the Application

```bash
# Get external IP (may take a few minutes)
kubectl get services --namespace=sample-app --watch
```

### Clean Up Sample Application

```bash
kubectl delete namespace sample-app
```

## Useful Commands

```bash
# View cluster information
kubectl cluster-info

# List all nodes
kubectl get nodes -o wide

# View node resource usage
kubectl top nodes

# List all namespaces
kubectl get namespaces

# View cluster events
kubectl get events --sort-by='.metadata.creationTimestamp'

# Access Kubernetes dashboard (if enabled)
az aks browse --resource-group rg-ecommerce-dev --name aks-ecommerce-dev
```

## Troubleshooting

### Common Issues

1. **Authentication Error**
   ```bash
   # Re-run kubectl configuration
   ./configure-kubectl.sh
   ```

2. **Node Issues**
   ```bash
   # Check node status
   kubectl describe nodes
   
   # Check cluster health
   kubectl get componentstatuses
   ```

3. **Resource Limits**
   ```bash
   # Check resource quotas
   kubectl describe quota --all-namespaces
   
   # Check resource usage
   kubectl top nodes
   kubectl top pods --all-namespaces
   ```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will permanently delete all resources created by Terraform.

## Cost Optimization Tips

1. **Use appropriate node sizes** for your workload
2. **Enable auto-scaling** to scale down during low usage
3. **Use spot instances** for non-critical workloads
4. **Monitor resource usage** with Azure Monitor
5. **Set up resource quotas** to prevent over-provisioning

## Security Best Practices

1. **Enable Azure Policy** for compliance
2. **Use network policies** for pod-to-pod communication
3. **Configure RBAC** with Azure AD groups
4. **Regular security updates** for node pools
5. **Monitor with Log Analytics** for security events

## Next Steps

- Set up CI/CD pipelines for application deployment
- Configure Ingress controllers (NGINX, Application Gateway)
- Set up monitoring and alerting with Prometheus/Grafana
- Implement GitOps with ArgoCD or Flux
- Configure backup strategies for persistent volumes

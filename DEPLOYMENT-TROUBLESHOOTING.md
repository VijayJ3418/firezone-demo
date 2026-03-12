# Deployment Troubleshooting Guide

## 🚨 Current Issue: Module Reference Error

### **Error Message**
```
Error: Reference to undeclared module
on outputs.tf line 5, in output "hub_network":
5:   value       = module.azure_networking_global
No module call named "azure_networking_global" is declared in the root module.
```

### **Root Cause**
The outputs.tf file is referencing modules before they are properly initialized by Terraform.

## 🔧 **Immediate Fix**

### **Step 1: Initialize Terraform**
```bash
cd Azure-code
terraform init
```

### **Step 2: Validate Configuration**
```bash
terraform validate
```

### **Step 3: Plan Deployment**
```bash
terraform plan
```

## 🚀 **Recommended Deployment Sequence**

### **Phase 1: Deploy Hub Network Only**

1. **Temporarily disable spoke and Jenkins modules in main.tf**:
   ```hcl
   # Comment out these modules temporarily
   # module "azure_core_infrastructure" { ... }
   # module "azure_jenkins_vm" { ... }
   ```

2. **Deploy hub network**:
   ```bash
   terraform apply -target=module.azure_networking_global -auto-approve
   ```

3. **Enable hub network output**:
   ```hcl
   output "hub_network" {
     description = "Hub network information"
     value       = module.azure_networking_global
   }
   ```

### **Phase 2: Deploy Spoke Network**

1. **Enable spoke module in main.tf**:
   ```hcl
   module "azure_core_infrastructure" {
     source = "./azure-core-infrastructure"
     # ... configuration
   }
   ```

2. **Deploy spoke network**:
   ```bash
   terraform apply -target=module.azure_core_infrastructure -auto-approve
   ```

### **Phase 3: Deploy Jenkins VM**

1. **Enable Jenkins VM module in main.tf**:
   ```hcl
   module "azure_jenkins_vm" {
     source = "./azure-jenkins-vm"
     # ... configuration
   }
   ```

2. **Deploy Jenkins VM**:
   ```bash
   terraform apply -target=module.azure_jenkins_vm -auto-approve
   ```

## 🛠️ **Alternative: Clean Deployment**

If the modular approach is causing issues, try a clean deployment:

### **Option 1: Destroy and Redeploy**
```bash
# Destroy existing resources
terraform destroy -auto-approve

# Clean Terraform state
rm -rf .terraform
rm terraform.tfstate*

# Reinitialize
terraform init

# Deploy everything
terraform apply -auto-approve
```

### **Option 2: Use Workspace**
```bash
# Create new workspace
terraform workspace new clean-deployment

# Deploy in new workspace
terraform apply -auto-approve
```

## 📝 **Current Configuration Status**

### **✅ Enabled Modules**
- `azure_networking_global` - Hub network
- `azure_core_infrastructure` - Spoke network  
- `azure_jenkins_vm` - Jenkins server

### **❌ Disabled Modules**
- `azure_core_infrastructure_secondary` - Secondary region
- `azure_firezone_multi_region` - Multi-region Firezone
- `azure_jenkins_appgw` - Application Gateway

### **🔧 Outputs Status**
- `hub_network` - Temporarily disabled
- `spoke_network` - Enabled
- `jenkins_vm` - Enabled
- `jenkins_access_info` - Enabled

## 🎯 **Expected Resources After Deployment**

### **Hub Network (East US)**
- Resource Group: `vijay-networking-global-rg`
- VNet: `vijay-vpc-hub` (172.16.0.0/16)
- Subnet: `subnet-vpn` (172.16.0.0/24)
- NSG: `vijay-hub-nsg-v5`

### **Spoke Network (East US)**
- Resource Group: `vijay-core-infrastructure-rg`
- VNet: `vijay-vpc-spoke` (192.168.0.0/16)
- Subnets:
  - `subnet-jenkins` (192.168.0.0/24)
  - `subnet-appgw` (192.168.128.0/23)
  - `subnet-vpn-v4` (192.168.131.0/24)
- VNet Peering: Hub ↔ Spoke
- DNS Zone: `dglearn.online`

### **Jenkins VM (East US)**
- VM: `jenkins-server` (Standard_DS1_v2)
- OS: Ubuntu 22.04 LTS
- Data Disk: 20 GB
- Private IP: Dynamic in subnet-jenkins

## 💰 **Cost Estimate**

| Resource | Monthly Cost (₹) |
|----------|------------------|
| VM (DS1_v2) | 1,800-2,200 |
| Storage | 300-500 |
| Networking | 200-400 |
| **Total** | **2,300-3,100** |

## 🔍 **Verification Commands**

### **Check Resource Groups**
```bash
az group list --query "[?contains(name, 'vijay')].{Name:name, Location:location}" -o table
```

### **Check Virtual Networks**
```bash
az network vnet list --query "[?contains(name, 'vijay')].{Name:name, AddressSpace:addressSpace.addressPrefixes}" -o table
```

### **Check VNet Peering**
```bash
az network vnet peering list --resource-group vijay-core-infrastructure-rg --vnet-name vijay-vpc-spoke -o table
```

### **Check VM Status**
```bash
az vm list --query "[?contains(name, 'jenkins')].{Name:name, PowerState:powerState, PrivateIP:privateIps}" -o table
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: Module Not Found**
**Solution**: Run `terraform init` to download modules

### **Issue 2: Resource Already Exists**
**Solution**: Import existing resources or destroy and recreate

### **Issue 3: Quota Exceeded**
**Solution**: Try different VM size or region

### **Issue 4: VNet Peering Fails**
**Solution**: Ensure both VNets exist before creating peering

## 📞 **Next Steps**

1. **Run terraform init** in the Azure-code directory
2. **Follow Phase 1** deployment (hub network only)
3. **Verify resources** in Azure portal
4. **Proceed to Phase 2** (spoke network)
5. **Complete with Phase 3** (Jenkins VM)

This step-by-step approach will avoid module dependency issues and ensure clean deployment!
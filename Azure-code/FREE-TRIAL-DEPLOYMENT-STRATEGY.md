# Azure Free Trial Deployment Strategy

## 🎯 Current Status & Next Steps

### ✅ **Completed Successfully**
- Hub Network (vijay-vpc-hub): 172.16.0.0/16
- Spoke Network (vijay-vpc-spoke): 192.168.0.0/16  
- VNet Peering: Hub ↔ Spoke connectivity
- DNS Zone: dglearn.online
- Network Security Groups: Configured

### 🚀 **Next Step: Deploy Jenkins VM**

## 📋 **Step-by-Step Deployment Plan**

### **Step 1: Deploy Hub Network First**
```bash
# Deploy only the hub network module
terraform apply -target=module.azure_networking_global
```

### **Step 2: Deploy Spoke Network**
```bash
# Deploy spoke network with hub peering
terraform apply -target=module.azure_core_infrastructure
```

### **Step 3: Deploy Jenkins VM**
```bash
# Deploy Jenkins VM with free trial compatible size
terraform apply -target=module.azure_jenkins_vm
```

### **Step 4: Deploy Application Gateway (Optional)**
```bash
# Deploy Application Gateway for HTTPS access
terraform apply -target=module.azure_jenkins_appgw
```

## 🖥️ **Free Trial Compatible VM Sizes**

### **Priority Order (Try in sequence)**

| VM Size | vCPU | RAM | Monthly Cost (₹) | Availability | Recommendation |
|---------|------|-----|------------------|--------------|----------------|
| **Standard_DS1_v2** | 1 | 3.5 GB | 1,800-2,200 | ⭐⭐⭐⭐ | **BEST CHOICE** |
| Standard_D1_v2 | 1 | 3.5 GB | 1,600-2,000 | ⭐⭐⭐ | Good alternative |
| Standard_F1s | 1 | 2 GB | 1,200-1,500 | ⭐⭐ | Current default |
| Standard_A1 | 1 | 1.75 GB | 1,000-1,200 | ⭐⭐⭐⭐ | Fallback option |
| Standard_A0 | 1 | 0.75 GB | 800-1,000 | ⭐⭐⭐⭐⭐ | Minimal Jenkins |

### **Why Standard_DS1_v2 is Recommended**
- ✅ **More RAM**: 3.5 GB (better for Jenkins)
- ✅ **Premium Storage**: Faster disk I/O
- ✅ **Better Availability**: D-series often available in free trials
- ✅ **Good Performance**: Suitable for development Jenkins

## 🌍 **Region Strategy**

### **Current Configuration**
- **Hub Network**: East US (already deployed)
- **Spoke Network**: East US (already deployed)
- **Jenkins VM**: East US (to be deployed)

### **Alternative Regions (if East US fails)**
1. **Central US** - Often has good availability
2. **South Central US** - Good for free trials
3. **West US 2** - Large capacity region
4. **North Central US** - Alternative option

## 🔧 **Deployment Commands**

### **Option 1: Sequential Deployment (Recommended)**
```bash
# Step 1: Hub Network
terraform apply -target=module.azure_networking_global -auto-approve

# Step 2: Spoke Network  
terraform apply -target=module.azure_core_infrastructure -auto-approve

# Step 3: Jenkins VM
terraform apply -target=module.azure_jenkins_vm -auto-approve
```

### **Option 2: Full Deployment**
```bash
# Deploy everything at once (riskier)
terraform apply -auto-approve
```

### **Option 3: Destroy and Redeploy (if needed)**
```bash
# Clean slate approach
terraform destroy -auto-approve
terraform apply -auto-approve
```

## 🛠️ **Troubleshooting VM Size Issues**

### **If Standard_DS1_v2 Fails**

1. **Try Standard_D1_v2**:
   ```hcl
   jenkins_vm_size = "Standard_D1_v2"
   ```

2. **Try Standard_A1**:
   ```hcl
   jenkins_vm_size = "Standard_A1"
   ```

3. **Try Different Region**:
   ```hcl
   location = "Central US"
   ```

4. **Check Azure Portal Manually**:
   - Go to "Create a resource" → "Virtual Machine"
   - Try different sizes in different regions
   - Note which combinations work

### **If All VM Sizes Fail**

#### **Alternative 1: Container-Based Jenkins**
Deploy Jenkins using Azure Container Instances:
- **Cost**: ~₹500-800/month
- **Availability**: Usually available
- **Setup**: Different deployment method

#### **Alternative 2: App Service Jenkins**
Deploy Jenkins on Azure App Service:
- **Cost**: ~₹600-1,000/month  
- **Availability**: High
- **Limitations**: Some plugins may not work

## 💰 **Cost Monitoring**

### **Expected Monthly Costs**
- **VM (DS1_v2)**: ₹1,800-2,200
- **Storage**: ₹300-500
- **Networking**: ₹200-400
- **Total**: ₹2,300-3,100/month

### **Budget Alerts**
Set up billing alerts at:
- ₹2,000 (early warning)
- ₹5,000 (mid-point)
- ₹8,000 (critical)

### **Cost Optimization**
- **Auto-shutdown**: Stop VM during non-working hours
- **Standard Storage**: Use Standard_LRS instead of Premium
- **Minimal Resources**: Start with smallest viable configuration

## 🔍 **Verification Steps**

After successful deployment, verify:

### **1. Network Connectivity**
```bash
# Check VNet peering
az network vnet peering list --resource-group vijay-networking-global-rg --vnet-name vijay-vpc-hub

# Check DNS resolution
nslookup jenkins.dglearn.online
```

### **2. VM Status**
```bash
# Check VM status
az vm show --resource-group vijay-core-infrastructure-rg --name jenkins-server --query "powerState"

# Get VM IP address
az vm show --resource-group vijay-core-infrastructure-rg --name jenkins-server --show-details --query "privateIps"
```

### **3. Jenkins Service**
```bash
# SSH to Jenkins VM
ssh azureuser@<jenkins-private-ip>

# Check Jenkins status
sudo systemctl status jenkins

# Check Jenkins logs
sudo journalctl -u jenkins -f
```

## 🚀 **Next Actions**

1. **Deploy Hub Network**: `terraform apply -target=module.azure_networking_global`
2. **Deploy Spoke Network**: `terraform apply -target=module.azure_core_infrastructure`  
3. **Deploy Jenkins VM**: `terraform apply -target=module.azure_jenkins_vm`
4. **Verify Connectivity**: SSH to Jenkins and check service status
5. **Access Jenkins**: Configure Application Gateway for HTTPS access

## 📞 **Support Options**

If you continue to face VM availability issues:

1. **Azure Support**: Submit a support ticket for quota increase
2. **Alternative Clouds**: Consider GCP or AWS free tiers
3. **Local Development**: Use Docker for local Jenkins testing
4. **Hybrid Approach**: Mix of cloud and local resources

Your ₹10,000 credit should be sufficient for 3-4 months of learning with the right VM configuration!
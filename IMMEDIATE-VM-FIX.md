# Immediate VM Deployment Fix

## 🚨 Current Issue
`Standard_DS1_v2` is not available in Central US for your free trial account.

## ✅ **Quick Solution: Try Standard_A1 in East US**

Since your networking is already in East US, let's deploy the VM there with a more available VM size.

### **Step 1: Try Standard_A1 (Most likely to work)**
```bash
terraform apply -target=module.azure_jenkins_vm -var="jenkins_vm_size=Standard_A1" -var="location=East US" -auto-approve
```

### **Step 2: If Standard_A1 fails, try Standard_A0**
```bash
terraform apply -target=module.azure_jenkins_vm -var="jenkins_vm_size=Standard_A0" -var="location=East US" -auto-approve
```

### **Step 3: If both fail, try Standard_D1_v2**
```bash
terraform apply -target=module.azure_jenkins_vm -var="jenkins_vm_size=Standard_D1_v2" -var="location=East US" -auto-approve
```

## 📊 **VM Size Comparison**

| VM Size | vCPU | RAM | Monthly Cost (₹) | Availability | Recommendation |
|---------|------|-----|------------------|--------------|----------------|
| **Standard_A1** | 1 | 1.75 GB | 1,000-1,200 | ⭐⭐⭐⭐⭐ | **BEST FOR FREE TRIAL** |
| Standard_A0 | 1 | 0.75 GB | 800-1,000 | ⭐⭐⭐⭐⭐ | Minimal but works |
| Standard_D1_v2 | 1 | 3.5 GB | 1,600-2,000 | ⭐⭐⭐ | Good if available |

## 🎯 **Why Standard_A1 is Better for Free Trial**

### **Advantages**
- ✅ **High Availability**: A-series VMs are almost always available
- ✅ **Lower Cost**: ~₹1,000/month vs ₹1,800 for DS1_v2
- ✅ **Sufficient for Jenkins**: 1.75 GB RAM is adequate for basic Jenkins
- ✅ **Free Trial Friendly**: Uses different quota pool than B/D/F series

### **Performance**
- **CPU**: 1 vCPU (sufficient for development Jenkins)
- **RAM**: 1.75 GB (can handle 5-10 concurrent builds)
- **Storage**: Standard_LRS (cost-optimized)
- **Network**: Basic performance (adequate for internal use)

## 🚀 **Expected Deployment Time**

- **VM Creation**: 3-5 minutes
- **Jenkins Installation**: 5-10 minutes (via startup script)
- **Total Time**: 8-15 minutes

## 🔍 **After Successful Deployment**

### **Verify VM Status**
```bash
# Check VM status
terraform output jenkins_vm

# Get VM details
az vm show --resource-group vijay-core-infrastructure-rg --name jenkins-server --query "{Name:name, PowerState:powerState, Size:hardwareProfile.vmSize, PrivateIP:privateIps}" -o table
```

### **Access Jenkins**
```bash
# SSH to Jenkins VM (replace with actual private IP)
ssh azureuser@<jenkins-private-ip>

# Check Jenkins status
sudo systemctl status jenkins

# Get Jenkins initial password
sudo cat /jenkins/jenkins_home/secrets/initialAdminPassword
```

### **Jenkins URL**
- **Internal Access**: `http://<jenkins-private-ip>:8080`
- **Via Bastion**: Use Azure Bastion for secure access

## 💰 **Cost Impact**

### **Monthly Cost with Standard_A1**
- **VM (A1)**: ₹1,000-1,200
- **Storage**: ₹300-500
- **Networking**: ₹200-400
- **Total**: ₹1,500-2,100/month

### **Savings vs DS1_v2**
- **Cost Reduction**: ₹800-1,100/month
- **Credit Extension**: 1-2 additional months of usage
- **Better Availability**: Higher success rate for deployment

## 🛠️ **If All VM Sizes Fail**

### **Alternative 1: Container-Based Jenkins**
```bash
# Deploy Jenkins using Azure Container Instances
az container create \
  --resource-group vijay-core-infrastructure-rg \
  --name jenkins-container \
  --image jenkins/jenkins:lts \
  --cpu 1 \
  --memory 2 \
  --ports 8080 \
  --environment-variables JENKINS_OPTS="--httpPort=8080"
```

### **Alternative 2: Different Time**
- **Try off-peak hours**: Early morning or late evening
- **Weekend deployment**: Often better availability
- **Wait 1-2 hours**: VM availability changes frequently

### **Alternative 3: Contact Azure Support**
```
Subject: Free Trial VM Quota Request
Message: "I'm using Azure free trial for learning purposes and need to deploy a small VM for Jenkins. All VM sizes are showing as unavailable in multiple regions. Could you please help increase my quota or suggest available VM sizes?"
```

## 🎯 **Success Indicators**

After successful deployment, you should see:
- ✅ VM created in East US
- ✅ Jenkins service running on port 8080
- ✅ Data disk mounted at `/jenkins`
- ✅ SSH access working
- ✅ VNet connectivity to hub network

## 📞 **Next Steps After VM Deployment**

1. **Verify Jenkins Installation**: Check service status
2. **Configure Jenkins**: Set up initial admin user
3. **Test Connectivity**: Ensure hub-spoke networking works
4. **Deploy Application Gateway**: For HTTPS access (optional)
5. **Set up Firezone VPN**: For secure remote access

The Standard_A1 VM size should work much better for your free trial account!
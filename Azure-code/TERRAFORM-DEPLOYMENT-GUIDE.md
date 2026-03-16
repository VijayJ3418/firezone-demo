# Terraform Cloud Deployment Guide

## 🚀 **READY TO DEPLOY - ALL FIXES APPLIED**

### **✅ Pre-Deployment Checklist:**
- ✅ **Latest Firezone Token**: Updated with fresh token
- ✅ **DNS Zone Conflict**: Fixed (only spoke network creates DNS zone)
- ✅ **Application Gateway IP**: Corrected to `10.0.2.50`
- ✅ **Key Vault Permissions**: Enhanced with purge permissions
- ✅ **Clean State**: All resources destroyed, ready for fresh deployment

## 📋 **DEPLOYMENT STEPS IN TERRAFORM CLOUD:**

### **Step 1: Access Your Terraform Cloud Workspace**
1. Go to [https://app.terraform.io](https://app.terraform.io)
2. Sign in to your account
3. Navigate to your Azure infrastructure workspace

### **Step 2: Upload Configuration Files**
**Option A: If using VCS (GitHub) integration:**
- Push your local changes to GitHub first
- Terraform Cloud will automatically detect changes

**Option B: If using CLI/manual upload:**
- Ensure your workspace has the latest configuration
- Upload the Azure-code directory contents

### **Step 3: Verify Variables**
Check that these variables are set in your workspace:
```
name_prefix = "vijay-"
location = "Central US"
firezone_token = "SFMyNTY.g2gDaANt...8B8cdGQC5doN0daa-aKVPRZfCQjd59QD8lEkLz1XgbM"
jenkins_vm_size = "Standard_D2s_v3"
enable_firezone_multi_region = true
enable_hub_peering = true
```

### **Step 4: Start Deployment**
1. **Click "Queue Plan"** in your workspace
2. **Review the Plan**: Should show creation of all resources
3. **Click "Confirm & Apply"** to start deployment

## 🎯 **EXPECTED DEPLOYMENT ORDER:**

### **Phase 1: Network Infrastructure (5-10 minutes)**
```
✅ Hub Network (172.16.0.0/16)
   ├── Resource Group
   ├── Virtual Network
   ├── Firezone Subnet
   └── Network Security Group

✅ Core IT Infrastructure (10.0.0.0/16)
   ├── Resource Group
   ├── Virtual Network
   ├── Jenkins Subnet (10.0.1.0/24)
   ├── Application Gateway Subnet (10.0.2.0/24)
   └── Network Security Groups

✅ Spoke Network (192.168.0.0/16)
   ├── Resource Group
   ├── Virtual Network
   ├── DNS Zone: dglearn.online
   └── VNet Links to Hub and Core IT
```

### **Phase 2: VNet Peering (2-3 minutes)**
```
✅ Hub ↔ Core IT Peering
✅ Hub ↔ Spoke Peering
✅ Network connectivity established
```

### **Phase 3: Firezone Gateways (10-15 minutes)**
```
✅ Firezone Primary Gateway VM
✅ Firezone Secondary Gateway VM
✅ Internal Load Balancer
✅ Backend Pool Configuration
✅ Health Probes
```

### **Phase 4: Jenkins Infrastructure (10-15 minutes)**
```
✅ Jenkins VM (Standard_D2s_v3)
✅ Data Disk (128GB)
✅ Network Interface
✅ Managed Identity
✅ Jenkins Installation & Configuration
```

### **Phase 5: Application Gateway (15-20 minutes)**
```
✅ Public IP Address
✅ Key Vault Creation
✅ SSL Certificate Generation
✅ Application Gateway Configuration
✅ HTTPS Listener Setup
✅ Backend Pool to Jenkins
```

## 📊 **MONITORING DEPLOYMENT:**

### **Watch for These Success Indicators:**
1. **Network Phase**: All VNets and subnets created
2. **Peering Phase**: Connectivity established between networks
3. **Firezone Phase**: VMs running, Load Balancer operational
4. **Jenkins Phase**: VM running with data disk attached
5. **Application Gateway Phase**: HTTPS endpoint ready

### **Common Deployment Times:**
- **Total Duration**: 45-60 minutes
- **Network Setup**: 5-10 minutes
- **VM Deployments**: 20-30 minutes
- **Application Gateway**: 15-20 minutes
- **Final Configuration**: 5-10 minutes

## 🎉 **POST-DEPLOYMENT VERIFICATION:**

### **Step 1: Check Firezone Connection**
1. **Go to Firezone Admin Portal**
2. **Navigate to Gateways section**
3. **Verify both gateways show "Connected" status**
4. **Check Load Balancer health**

### **Step 2: Test VPN Access**
1. **Download Firezone client**
2. **Connect to VPN**
3. **Access Jenkins**: `http://10.0.1.x:8080`

### **Step 3: Test HTTPS Access**
1. **Open browser**
2. **Navigate to**: `https://jenkins-azure.dglearn.online`
3. **Verify SSL certificate**
4. **Confirm Jenkins loads**

### **Step 4: Verify Infrastructure**
1. **Azure Portal**: Check all resources deployed
2. **Network Connectivity**: Test cross-VNet communication
3. **DNS Resolution**: Verify name resolution works
4. **Security Groups**: Confirm proper access controls

## 🚨 **IF ISSUES OCCUR:**

### **Common Solutions:**
1. **Firezone Not Connecting**: Check VM boot diagnostics, verify token
2. **DNS Issues**: Verify VNet links are created
3. **Application Gateway Errors**: Check Key Vault permissions
4. **Network Issues**: Verify NSG rules and peering

### **Troubleshooting Commands:**
```bash
# Check Firezone service status (if SSH access available)
sudo systemctl status firezone-gateway

# Check network connectivity
ping 8.8.8.8

# Check DNS resolution
nslookup jenkins-azure.dglearn.online
```

## 🎯 **SUCCESS CRITERIA:**

**Your deployment is successful when:**
- ✅ **All Terraform resources**: Created without errors
- ✅ **Firezone gateways**: Show "Connected" in admin portal
- ✅ **VPN access**: Can connect and reach Jenkins privately
- ✅ **HTTPS access**: `https://jenkins-azure.dglearn.online` works
- ✅ **SSL certificate**: Valid and trusted
- ✅ **Network connectivity**: All VNets can communicate

## 🚀 **READY TO DEPLOY!**

**Your infrastructure configuration is optimized and ready for deployment. All known issues have been resolved.**

**Go to Terraform Cloud and click "Queue Plan" to begin your successful Azure infrastructure deployment!** 🎉
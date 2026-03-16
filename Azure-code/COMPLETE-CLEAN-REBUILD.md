# Complete Clean Rebuild Guide

## 🔄 **Clean Rebuild Strategy**

All modules have been **re-enabled** and **properly configured** for a complete fresh deployment.

## ✅ **Modules Re-Enabled:**

### **1. Application Gateway Module**
- **Status**: ✅ **ENABLED**
- **Purpose**: HTTPS access to Jenkins at `https://jenkins-azure.dglearn.online`
- **Location**: Core IT Infrastructure VNet
- **Features**: SSL termination, backend pool to Jenkins VM

### **2. DNS Zone Configuration**
- **Status**: ✅ **ENABLED**
- **Purpose**: Private DNS resolution for `dglearn.online`
- **VNet Links**: Core IT VNet + Hub VNet
- **Clean deployment**: No conflicts with fresh state

### **3. NSG with Outbound Rules**
- **Status**: ✅ **ENABLED**
- **Purpose**: Internet access for Firezone gateways
- **Rules**: HTTPS, HTTP, DNS, NTP outbound
- **Association**: Firezone subnet in hub network

### **4. All Network Components**
- **Hub Network**: ✅ With Firezone subnet and enhanced NSG
- **Core IT Infrastructure**: ✅ With Jenkins and Application Gateway subnets
- **Spoke Network**: ✅ Available for other workloads
- **VNet Peering**: ✅ Between all networks

### **5. Firezone Multi-Region**
- **Status**: ✅ **ENABLED**
- **Gateways**: Primary + Secondary in hub network
- **Load Balancer**: Internal LB for high availability
- **Internet Access**: Through enhanced NSG rules

### **6. Jenkins VM**
- **Status**: ✅ **ENABLED**
- **Location**: Core IT Infrastructure VNet
- **Disks**: OS disk + separate data disk
- **Access**: Private IP only, VPN + HTTPS access

## 🚀 **Deployment Steps:**

### **Step 1: Destroy All Resources**
```bash
# In Terraform Cloud workspace
# Queue a "Destroy" run to remove all existing resources
```

### **Step 2: Push Updated Code**
```bash
# All modules are now enabled and properly configured
git add .
git commit -m "COMPLETE REBUILD: Enable all modules with NSG fixes and proper architecture"
git push origin main
```

### **Step 3: Apply Fresh Deployment**
```bash
# In Terraform Cloud workspace
# Queue a "Plan and Apply" run for complete fresh deployment
```

## 📊 **Expected Deployment Order:**

### **Phase 1: Network Foundation**
1. ✅ **Hub Network** (172.16.0.0/16) with enhanced NSG
2. ✅ **Core IT Infrastructure** (10.0.0.0/16) with subnets
3. ✅ **Spoke Network** (192.168.0.0/16) for other workloads
4. ✅ **VNet Peering** between all networks
5. ✅ **DNS Zone** with proper VNet links

### **Phase 2: Compute Resources**
1. ✅ **Firezone Gateways** (Primary + Secondary) in hub
2. ✅ **Internal Load Balancer** for Firezone HA
3. ✅ **Jenkins VM** in Core IT Infrastructure
4. ✅ **Application Gateway** for HTTPS access

### **Phase 3: Connectivity**
1. ✅ **NSG Rules** enable internet access for gateways
2. ✅ **Firezone startup** downloads packages successfully
3. ✅ **Gateways connect** to Firezone control plane
4. ✅ **HTTPS access** through Application Gateway

## 🎯 **Success Criteria:**

### **✅ Network Architecture:**
- Hub network with Firezone gateways ✅
- Core IT network with Jenkins VM ✅
- Application Gateway for HTTPS ✅
- All VNet peering working ✅

### **✅ Firezone VPN:**
- Both gateways show "Connected" in admin console ✅
- Load Balancer distributing traffic ✅
- VPN clients can connect ✅

### **✅ Jenkins Access:**
- Private IP only (no public access) ✅
- HTTPS access: `https://jenkins-azure.dglearn.online` ✅
- VPN access through Firezone ✅
- SSH access from specified IP ranges ✅

### **✅ Security:**
- No public IPs on VMs ✅
- NSG rules for controlled access ✅
- VPN-only access model ✅
- Separate data disk for Jenkins ✅

## 🔧 **Key Fixes Applied:**

### **1. NSG Outbound Rules**
```terraform
# HTTPS outbound for package downloads and Firezone API
# HTTP outbound for package repositories
# DNS outbound for domain resolution
# NTP outbound for time synchronization
# VNet-to-VNet communication
```

### **2. Proper Module Dependencies**
```terraform
# Application Gateway depends on Jenkins VM
# Jenkins VM depends on Core IT Infrastructure
# Firezone depends on Hub Network
# All modules properly sequenced
```

### **3. Correct Network Assignments**
```terraform
# Firezone gateways → Hub Network (172.16.3.0/24)
# Jenkins VM → Core IT Infrastructure (10.0.1.0/24)
# Application Gateway → Core IT Infrastructure (10.0.2.0/24)
```

## 📋 **Post-Deployment Verification:**

### **1. Check Firezone Admin Console**
- Sites should show "Online Gateways"
- Resources should be accessible
- Gateway status: Connected

### **2. Test HTTPS Access**
```bash
curl -k https://jenkins-azure.dglearn.online
```

### **3. Test VPN Connectivity**
- Connect VPN client to Load Balancer IP
- Access Jenkins through private IP
- Verify DNS resolution

### **4. Test SSH Access**
```bash
# From allowed IP ranges
ssh azureuser@10.0.1.4
```

## 🎉 **Expected Final State:**

A complete, working Azure infrastructure with:
- ✅ **Secure VPN access** through Firezone
- ✅ **HTTPS web access** through Application Gateway
- ✅ **Private Jenkins** with separate data disk
- ✅ **High availability** Firezone gateways
- ✅ **Proper network segmentation**
- ✅ **All security requirements** met

The clean rebuild will resolve all state conflicts and deploy everything correctly from scratch!
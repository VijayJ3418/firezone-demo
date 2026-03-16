# Complete Infrastructure Rebuild Plan

## 🎯 Objectives
- ✅ **Clean slate**: Destroy all existing resources
- ✅ **Fix Terraform state**: Clean up any state conflicts
- ✅ **VPN-only access**: No public IPs on any resources
- ✅ **Working Firezone**: Properly configured gateways with real token
- ✅ **Secure architecture**: Access only through Firezone VPN

## 📋 Step-by-Step Rebuild Process

### Phase 1: Complete Cleanup
1. **Destroy all resources** via Terraform Cloud
2. **Clean Terraform state** 
3. **Verify Azure resources deleted**

### Phase 2: Configuration Updates
1. **Disable all public IPs** (Jenkins, Firezone gateways)
2. **Configure Firezone startup script** with better error handling
3. **Add Azure Bastion** for initial access and troubleshooting
4. **Update network security groups** for VPN-only access

### Phase 3: Fresh Deployment
1. **Deploy hub-spoke network** with Bastion
2. **Deploy Jenkins VM** (private IP only)
3. **Deploy Firezone gateways** (private IP only)
4. **Verify Firezone registration**

### Phase 4: VPN Configuration
1. **Test Firezone gateway connectivity**
2. **Create VPN client configuration**
3. **Verify VPN-only access to resources**

## 🚀 Let's Start: Phase 1 - Complete Cleanup

### Step 1: Terraform Destroy
In Terraform Cloud:
1. **Queue Destroy Plan**
2. **Review destroy plan** (should remove all resources)
3. **Apply destroy** (this will clean up everything)

### Step 2: Manual Cleanup (if needed)
If Terraform destroy fails, manually delete in Azure Portal:
- Resource Group: `vijay-core-infrastructure-rg`
- Any remaining networking resources
- DNS zones if created

### Step 3: Clean Terraform State
After successful destroy:
- Terraform state should be clean
- No manual state cleanup needed if destroy succeeds

## 🔧 Phase 2: Updated Configuration

I'll update the configuration with these changes:
- ✅ **No public IPs** on any VMs
- ✅ **Azure Bastion** for secure access
- ✅ **Improved Firezone startup script**
- ✅ **Better error handling and logging**
- ✅ **VPN-only network security rules**

## 📊 Expected Final Architecture

```
Internet
    ↓
Azure Bastion (for admin access only)
    ↓
Hub Network (172.16.0.0/16)
    ├── Bastion Subnet
    └── Gateway Subnet
    ↓
Spoke Network (192.168.0.0/16)
    ├── Jenkins Subnet (192.168.0.0/24)
    │   └── Jenkins VM (private IP only)
    └── VPN Subnet (192.168.131.0/24)
        ├── Primary Firezone Gateway (private IP only)
        └── Secondary Firezone Gateway (private IP only)
```

## 🎯 Access Model
- **Admin access**: Azure Bastion → VMs
- **User access**: Firezone VPN → Internal resources
- **No direct internet access** to any VMs

Ready to proceed with Phase 1 (Destroy)?
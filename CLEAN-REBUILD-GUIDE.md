# Complete Clean Rebuild Guide

## 🎯 Final Architecture (VPN-Only Access)

```
Internet
    ↓
Firezone Control Plane (api.firezone.dev)
    ↓
Hub Network (172.16.0.0/16)
    └── No public resources
    ↓
Spoke Network (192.168.0.0/16)
    ├── Jenkins Subnet (192.168.0.0/24)
    │   └── Jenkins VM (private IP only)
    └── VPN Subnet (192.168.131.0/24)
        ├── Primary Firezone Gateway (private IP only)
        └── Secondary Firezone Gateway (private IP only)
```

## 🚀 Step 1: Complete Cleanup

### Terraform Cloud Destroy
1. **Go to Terraform Cloud workspace**
2. **Settings → Destruction and Deletion**
3. **Queue destroy plan**
4. **Review destroy plan** (should remove all resources)
5. **Apply destroy** (this will clean up everything)

### Verify Cleanup
After destroy completes:
- Check Azure Portal - Resource Group should be empty or deleted
- Terraform state should be clean
- No manual cleanup needed if destroy succeeds

## 🔧 Step 2: Updated Configuration Summary

### Changes Made:
- ✅ **No public IPs**: All VMs are private-only
- ✅ **No Bastion**: VPN-only access as requested
- ✅ **Real Firezone token**: Latest token configured
- ✅ **Improved startup script**: Better error handling
- ✅ **Clean state**: Fresh deployment without conflicts

### Network Configuration:
- **Hub Network**: 172.16.0.0/16 (no public resources)
- **Spoke Network**: 192.168.0.0/16 (all private)
- **Jenkins Subnet**: 192.168.0.0/24 (private)
- **VPN Subnet**: 192.168.131.0/24 (private)

## 🚀 Step 3: Fresh Deployment

### Deploy Command
1. **Go to Terraform Cloud workspace**
2. **Start new run** (Queue plan)
3. **Review the plan** - should show:
   - Hub-spoke network architecture
   - Jenkins VM (private IP only)
   - Two Firezone gateways (private IP only)
   - No public IP resources
4. **Apply the changes**

### Expected Resources:
- ✅ **Resource Group**: `vijay-core-infrastructure-rg`
- ✅ **Hub VNet**: `vijay-vpc-hub` (172.16.0.0/16)
- ✅ **Spoke VNet**: `vijay-vpc-spoke` (192.168.0.0/16)
- ✅ **VNet Peering**: Hub ↔ Spoke
- ✅ **DNS Zone**: `dglearn.online`
- ✅ **Jenkins VM**: `vijay-jenkins-vm` (private IP)
- ✅ **Primary Gateway**: `vijay-primary-firezone-gateway` (private IP)
- ✅ **Secondary Gateway**: `vijay-secondary-firezone-gateway` (private IP)

## 🔍 Step 4: Verify Firezone Registration

### Check Firezone Admin Portal
1. **Login to Firezone admin portal**
2. **Navigate to Gateways section**
3. **Wait 5-10 minutes** for gateways to register
4. **Verify both gateways show "Online" status**

### If Gateways Don't Register:
Use Azure Run Command to troubleshoot:

```bash
# Check Firezone status
cd /opt/firezone
sudo -u azureuser docker compose ps
sudo -u azureuser docker compose logs --tail=20

# Restart if needed
sudo -u azureuser docker compose down
sudo -u azureuser docker compose up -d
```

## 🔐 Step 5: VPN Client Setup

### Create VPN Client
1. **In Firezone admin portal**
2. **Go to Clients section**
3. **Add new client**
4. **Download WireGuard configuration**

### Test VPN Access
1. **Install WireGuard client**
2. **Import configuration**
3. **Connect to VPN**
4. **Test access to private resources**:
   - Jenkins: `http://192.168.0.x:8080`
   - Gateway health: `http://192.168.131.x:8080`

## 📊 Expected Final State

### Security Benefits:
- ✅ **No public IPs**: Zero internet exposure
- ✅ **VPN-only access**: All resources behind Firezone VPN
- ✅ **Network segmentation**: Hub-spoke architecture
- ✅ **Encrypted access**: WireGuard VPN encryption

### Access Model:
- **Admin access**: Firezone VPN → Azure Run Command (if needed)
- **User access**: Firezone VPN → Internal resources
- **No direct internet access** to any Azure resources

## 🎯 Ready to Start?

1. **Destroy existing resources** in Terraform Cloud
2. **Wait for cleanup to complete**
3. **Deploy fresh infrastructure** with VPN-only configuration
4. **Verify Firezone gateways register**
5. **Set up VPN client and test access**

This approach gives you a completely secure, VPN-only infrastructure with working Firezone gateways!
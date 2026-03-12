# Azure Free Trial Optimization Guide

## 💰 Cost-Optimized Configuration for ₹10,000 Credit

### **VM Sizes Updated for Free Trial**

#### **Jenkins VM: Standard_A1_v2**
- **vCPUs**: 1
- **RAM**: 2 GB
- **Cost**: ~₹1,500-2,000/month
- **Storage**: Standard_LRS (cheaper than Premium)
- **Availability**: High in most regions

#### **Firezone VMs: Standard_A1_v2**
- **vCPUs**: 1 each
- **RAM**: 2 GB each
- **Cost**: ~₹1,500/month per VM
- **Total for 2 VMs**: ~₹3,000/month

### **Storage Optimization**
- **OS Disk**: Standard_LRS (₹200-300/month per disk)
- **Data Disk**: Standard_LRS (₹100-200/month per disk)
- **Total Storage**: ~₹800-1,200/month

### **Network Costs**
- **VNet Peering**: Free within same region
- **Load Balancer**: ~₹500-800/month
- **Public IPs**: ~₹200-400/month

## 📊 Estimated Monthly Costs

| Component | Cost (₹/month) |
|-----------|----------------|
| Jenkins VM (A1_v2) | 1,500-2,000 |
| Firezone VM 1 (A1_v2) | 1,500 |
| Firezone VM 2 (A1_v2) | 1,500 |
| Storage (All disks) | 800-1,200 |
| Load Balancer | 500-800 |
| Networking | 200-400 |
| **Total** | **6,000-7,900** |

## ✅ Free Trial Compatible VM Sizes

### **Commonly Available in Free Trial**
1. **Standard_A1_v2** ✅ (Current choice)
   - 1 vCPU, 2 GB RAM
   - Generation 1 compatible
   - Works with Standard storage

2. **Standard_B1ls** (Alternative)
   - 1 vCPU, 0.5 GB RAM
   - Very low cost but limited RAM

3. **Standard_D1_v2** (Alternative)
   - 1 vCPU, 3.5 GB RAM
   - Slightly more expensive

### **Regions with Better Availability**
1. **East US** - Best availability
2. **West US 2** - Good availability  
3. **Central US** - Good availability
4. **South Central US** - Alternative

## 🚀 Deployment Strategy

### **Phase 1: Core Infrastructure (₹0)**
- VNets, Subnets, NSGs, DNS
- **Cost**: Free

### **Phase 2: Jenkins VM (₹1,500-2,000/month)**
- Single Jenkins server
- Standard storage
- **Test first before adding more VMs**

### **Phase 3: Firezone VMs (₹3,000/month additional)**
- Add after Jenkins is working
- Multi-region VPN setup

## 💡 Cost Saving Tips

### **1. Use Spot Instances (Advanced)**
- 60-90% cost reduction
- Risk: VM can be deallocated

### **2. Auto-shutdown Schedule**
- Stop VMs during non-working hours
- Save 50-70% on compute costs

### **3. Monitor Usage**
- Set up billing alerts
- Track spending daily

### **4. Start Small**
- Deploy only Jenkins first
- Add Firezone later if needed

## 🔧 Current Configuration Changes

✅ **VM Size**: Standard_B1s → Standard_A1_v2
✅ **OS Image**: Gen2 → Gen1 (A-series compatible)
✅ **Storage**: Premium_LRS → Standard_LRS
✅ **Regions**: Optimized for availability

## 📋 Next Steps

1. **Deploy Jenkins VM first** with new A1_v2 configuration
2. **Test Jenkins functionality** 
3. **Monitor costs** for 1-2 weeks
4. **Add Firezone VMs** if budget allows
5. **Set up auto-shutdown** to optimize costs

Your ₹10,000 credit should last 1-2 months with this configuration, giving you plenty of time to test and learn!
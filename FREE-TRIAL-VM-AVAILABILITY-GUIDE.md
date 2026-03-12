# Azure Free Trial VM Availability Guide

## 🚨 Current Challenge: VM Size Availability

Your free trial account has very limited VM quota, and we've tried multiple combinations:

### **Attempted Configurations**
1. ❌ **Standard_D2s_v3** in East US - Not available
2. ❌ **Standard_B1ms** in East US - Not available  
3. ❌ **Standard_B1s** in West US 2 - Not available
4. ❌ **Standard_A1_v2** in West US 2 - Not available
5. ❌ **Standard_A1_v2** in East US - Not available
6. ❌ **Standard_B1ls** in East US - Not available

### **Current Attempt**
- **VM Size**: Standard_F1s (1 vCPU, 2 GB RAM)
- **Region**: Central US
- **Reason**: F-series often has better availability than B-series

## 🎯 **Standard_F1s Specifications**

### **Performance**
- **vCPUs**: 1
- **RAM**: 2 GB (4x more than B1ls)
- **Storage**: Premium SSD supported
- **Network**: Moderate performance
- **Cost**: ~₹1,200-1,500/month

### **Benefits Over B1ls**
- ✅ **More RAM**: 2 GB vs 0.5 GB (better for Jenkins)
- ✅ **Better Performance**: F-series optimized for compute
- ✅ **Premium Storage**: Faster disk I/O
- ✅ **Different Quota**: Uses F-series quota instead of B-series

## 🌍 **Region Strategy**

### **Priority Order for Free Trial**
1. **Central US** ⭐ (Current attempt)
2. **South Central US** 
3. **West US**
4. **North Central US**
5. **East US 2**

### **Why Central US?**
- **Large capacity**: Major Azure region
- **Free trial friendly**: Often has quota available
- **Good connectivity**: Central location in US
- **Cost effective**: Standard pricing tier

## 🔄 **Deployment Strategy**

### **Current Status**
✅ **Networking**: Successfully deployed in East US
- Hub VNet: `vijay-vpc-hub` (172.16.0.0/16)
- Spoke VNet: `vijay-vpc-spoke` (192.168.0.0/16)
- VNet Peering: Working
- DNS Zone: `dglearn.online`

### **Next Steps**
Since networking is in East US but we need Central US for VM:

#### **Option 1: Cross-Region Deployment** (Current)
- Keep networking in East US
- Deploy VM in Central US
- Use VNet peering across regions

#### **Option 2: Full Redeploy** (If Option 1 fails)
- Destroy all infrastructure
- Redeploy everything in Central US
- Clean slate approach

## 💡 **Alternative VM Sizes to Try**

If Standard_F1s fails, try these in order:

### **1. Standard_DS1_v2**
- **Specs**: 1 vCPU, 3.5 GB RAM
- **Cost**: ~₹1,800/month
- **Availability**: Often available in free trials

### **2. Standard_D1_v2**
- **Specs**: 1 vCPU, 3.5 GB RAM  
- **Cost**: ~₹1,600/month
- **Availability**: Good for free trials

### **3. Standard_A0**
- **Specs**: 1 vCPU, 0.75 GB RAM
- **Cost**: ~₹800/month
- **Availability**: Basic tier, usually available

### **4. Standard_A1**
- **Specs**: 1 vCPU, 1.75 GB RAM
- **Cost**: ~₹1,000/month
- **Availability**: Classic tier

## 🛠️ **Troubleshooting Steps**

### **If Standard_F1s Fails**

1. **Try Different Region**:
   ```hcl
   location = "South Central US"
   ```

2. **Try Different VM Size**:
   ```hcl
   jenkins_vm_size = "Standard_DS1_v2"
   ```

3. **Check Azure Portal**:
   - Go to "Create a resource" → "Virtual Machine"
   - Select your subscription
   - Try different regions and sizes manually

4. **Contact Azure Support**:
   - Request quota increase for specific VM family
   - Explain it's for learning purposes

### **If All VM Sizes Fail**

#### **Option A: Use Azure Container Instances**
Deploy Jenkins as a container instead of VM:
- **Cost**: ~₹500-800/month
- **Availability**: Usually available
- **Performance**: Good for basic Jenkins

#### **Option B: Use Azure App Service**
Deploy Jenkins on App Service:
- **Cost**: ~₹600-1,000/month
- **Availability**: High
- **Limitations**: Some Jenkins features may not work

#### **Option C: Different Cloud Provider**
Consider using:
- **Google Cloud**: $300 free credit
- **AWS**: 12 months free tier
- **Oracle Cloud**: Always free tier

## 📊 **Cost Comparison**

| VM Size | vCPU | RAM | Monthly Cost (₹) | Availability |
|---------|------|-----|------------------|--------------|
| Standard_F1s | 1 | 2 GB | 1,200-1,500 | Medium |
| Standard_DS1_v2 | 1 | 3.5 GB | 1,800-2,200 | Good |
| Standard_D1_v2 | 1 | 3.5 GB | 1,600-2,000 | Good |
| Standard_A1 | 1 | 1.75 GB | 1,000-1,200 | High |
| Standard_A0 | 1 | 0.75 GB | 800-1,000 | Very High |

## 🎯 **Success Criteria**

After successful deployment, you should have:

- ✅ **Jenkins VM**: Running in Central US
- ✅ **Network Connectivity**: Cross-region VNet peering
- ✅ **SSH Access**: Key-based authentication
- ✅ **Jenkins Service**: Auto-installed and running
- ✅ **Data Disk**: Mounted at `/jenkins`
- ✅ **Cost**: Within ₹10,000 credit limit

## 🚀 **Next Actions**

1. **Try Standard_F1s in Central US** (current attempt)
2. **If fails**: Try South Central US
3. **If fails**: Try Standard_DS1_v2
4. **If fails**: Consider container-based approach

The key is persistence - free trial accounts have very limited quotas, but there's usually at least one VM size/region combination that works!

## 💭 **Pro Tips**

### **Timing Matters**
- **Try different times**: VM availability changes throughout the day
- **Weekend deployment**: Often better availability
- **Early morning**: Less competition for resources

### **Multiple Attempts**
- **Don't give up**: Try 3-4 different combinations
- **Small delays**: Wait 10-15 minutes between attempts
- **Different browsers**: Sometimes helps with quota detection

### **Monitoring**
- **Set billing alerts**: ₹2,000, ₹5,000, ₹8,000
- **Daily cost check**: Monitor Azure portal
- **Resource cleanup**: Delete unused resources immediately

Your ₹10,000 credit is sufficient for 6-8 months of learning with the right VM size!
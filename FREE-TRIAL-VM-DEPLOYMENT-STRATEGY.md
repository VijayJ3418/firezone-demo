# Free Trial VM Deployment Strategy

## 🚨 Current Issue: VM Size Availability

Your free trial account has quota restrictions that prevent deployment of most VM sizes. Here's the solution:

## ✅ Updated Configuration

### **Changes Made**
- **Region**: West US 2 → **East US** (better free trial availability)
- **VM Size**: Standard_A1_v2 → **Standard_B1ls** (most commonly available)
- **VM Specs**: 1 vCPU, 0.5 GB RAM (minimal but functional)
- **Image**: Ubuntu 22.04 LTS Gen2 (B-series compatible)

### **Why Standard_B1ls?**
- **Most Available**: Highest success rate in free trial accounts
- **Lowest Cost**: ~₹800-1,000/month
- **Burstable**: Can handle occasional load spikes
- **Sufficient**: Adequate for Jenkins testing and learning

## 🚀 Deployment Options

### **Option 1: Destroy and Redeploy (Recommended)**

Since you're changing both region and VM size, the cleanest approach is:

1. **Destroy existing infrastructure**:
   ```
   In Terraform Cloud: terraform destroy
   ```

2. **Deploy with new configuration**:
   ```
   In Terraform Cloud: terraform apply
   ```

**Benefits**:
- ✅ Clean deployment in East US
- ✅ No resource conflicts
- ✅ Uses Standard_B1ls VM size
- ✅ Proper region alignment

### **Option 2: Try Alternative VM Sizes**

If you want to keep West US 2, try these VM sizes in order:

1. **Standard_B1ls** (1 vCPU, 0.5 GB) - Most likely to work
2. **Standard_B1ms** (1 vCPU, 2 GB) - If B1ls not available
3. **Standard_F1s** (1 vCPU, 2 GB) - Alternative option

### **Option 3: Try Different Regions**

Free trial VM availability by region (best to worst):

1. **East US** ✅ (Recommended)
2. **Central US** ✅
3. **South Central US** ✅
4. **West US 2** ⚠️ (Limited availability)
5. **West Europe** ⚠️
6. **Southeast Asia** ⚠️

## 📋 Step-by-Step Deployment

### **Step 1: Destroy Current Infrastructure**

In Terraform Cloud:
```
terraform destroy
```

Wait for completion (5-10 minutes).

### **Step 2: Verify Configuration**

The updated configuration includes:
```hcl
# Primary region
location = "East US"

# VM size
jenkins_vm_size = "Standard_B1ls"

# Secondary region (for future Firezone)
secondary_region = "West US 2"
```

### **Step 3: Deploy New Infrastructure**

In Terraform Cloud:
```
terraform apply
```

This will create:
- ✅ Hub network in East US
- ✅ Spoke network in East US
- ✅ VNet peering
- ✅ Jenkins VM with Standard_B1ls

### **Step 4: Test Jenkins VM**

After deployment:
```bash
# SSH to Jenkins VM
ssh azureuser@<jenkins-vm-ip>

# Check Jenkins installation
sudo systemctl status jenkins

# Check disk space
df -h

# Check memory usage
free -h
```

## 💰 Cost Impact

### **Standard_B1ls Costs (Monthly)**

| Component | Cost (₹) |
|-----------|----------|
| VM (B1ls) | 800-1,000 |
| OS Disk (32GB Standard) | 200-300 |
| Data Disk (20GB Standard) | 100-150 |
| Networking | 100-200 |
| **Total** | **1,200-1,650** |

### **Budget Utilization**
- **Monthly Cost**: ₹1,200-1,650
- **Your Credit**: ₹10,000
- **Duration**: 6-8 months of usage
- **Remaining**: ₹8,000+ for Firezone and other services

## ⚠️ Standard_B1ls Limitations

### **Performance Considerations**
- **RAM**: Only 0.5 GB (Jenkins may be slow)
- **CPU**: 1 vCPU (sufficient for basic Jenkins)
- **Disk I/O**: Standard storage (slower than Premium)
- **Network**: Basic networking performance

### **Jenkins Optimization for B1ls**
The startup script will be optimized for low memory:

```bash
# Reduce Jenkins memory usage
export JAVA_OPTS="-Xmx256m -Xms128m"

# Use lightweight plugins only
# Disable unnecessary features
# Use external storage for artifacts
```

### **Monitoring Resource Usage**
```bash
# Check memory usage
free -h
watch -n 5 free -h

# Check CPU usage
htop

# Check disk usage
df -h
du -sh /jenkins/*
```

## 🔧 Troubleshooting

### **If B1ls Still Fails**

Try these alternatives in order:

1. **Different Region**:
   ```hcl
   location = "Central US"
   ```

2. **Different VM Size**:
   ```hcl
   jenkins_vm_size = "Standard_F1s"
   ```

3. **Contact Azure Support**:
   - Request quota increase for specific VM family
   - Explain it's for learning/testing purposes

### **If Memory Issues Occur**

```bash
# Add swap space
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 🎯 Success Criteria

After deployment, you should have:

- ✅ Jenkins VM running in East US
- ✅ Jenkins accessible via private IP
- ✅ SSH access working
- ✅ Data disk mounted at `/jenkins`
- ✅ Jenkins service running
- ✅ Basic functionality tested

## 📈 Next Steps After Success

1. **Test Jenkins functionality**
2. **Create a simple pipeline**
3. **Monitor resource usage**
4. **Consider upgrading to B1ms if needed**
5. **Plan Firezone deployment**

## 💡 Pro Tips

### **Optimize for Free Trial**
- **Use Standard storage** everywhere
- **Minimize data transfer** between regions
- **Set up billing alerts** at ₹2,000, ₹5,000, ₹8,000
- **Monitor daily usage** in Azure portal

### **Resource Management**
- **Stop VMs** when not in use (saves 70-80% on compute)
- **Use auto-shutdown** policies
- **Delete unused resources** regularly
- **Monitor cost daily** in Azure portal

The Standard_B1ls configuration should work in East US for your free trial account. This gives you a functional Jenkins environment to learn and test with, while staying well within your ₹10,000 credit limit!
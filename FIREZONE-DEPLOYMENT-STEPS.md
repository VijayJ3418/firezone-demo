# Firezone Gateway Deployment - Step by Step

## Current Issue & Solution

The deployment is failing because Azure can't delete public IPs that are still attached to network interfaces. This is a common Azure dependency issue when transitioning from public to private IPs.

## ✅ Solution: Two-Step Deployment Process

### Step 1: Deploy with Temporary Public IPs
First, let's get the Firezone gateways deployed and working with the real token.

### Step 2: Remove Public IPs After Successful Deployment
Once everything is working, we'll remove the public IPs for security.

## 🚀 Step 1: Deploy Firezone Gateways

### Current Configuration:
- ✅ **Real Firezone Token**: Latest token from admin portal
- ✅ **Temporary Public IPs**: Enabled to avoid Azure dependency issues
- ✅ **Dual Gateway Setup**: Primary and secondary gateways
- ✅ **Automatic Setup**: Complete Firezone installation via startup script

### Deploy Now:
1. **Go to Terraform Cloud workspace**
2. **Start new run** (Queue plan)
3. **Review the plan** - should show:
   - Two Firezone gateway VMs
   - Two public IPs (temporary)
   - No Load Balancer resources
4. **Apply the changes**

## 🔧 Step 2: Verify Firezone is Working

After successful deployment:

### Check Gateway Status:
```bash
# SSH to primary gateway
ssh azureuser@<primary-public-ip>

# Check Firezone status
cd /opt/firezone
sudo -u azureuser docker compose ps
sudo -u azureuser docker compose logs

# Verify Firezone is running
curl http://localhost:8080
```

### Verify in Firezone Admin Portal:
1. **Login to Firezone admin portal**
2. **Go to Gateways section**
3. **Verify both gateways are registered** and showing as "Online"
4. **Test VPN connection** with a client

## 🔒 Step 3: Remove Public IPs (After Verification)

Once Firezone is confirmed working:

### Update Configuration:
```terraform
# In azure-firezone-multi-region/main.tf
# Change both modules:
enable_public_ip = false  # Change from true to false
```

### Deploy Security Update:
1. **Commit the change**
2. **Apply in Terraform Cloud**
3. **Gateways will be private-only**

## 📊 Expected Results

### After Step 1 (Current):
- ✅ **Two working Firezone gateways** with real token
- ✅ **Public IPs for initial access** and verification
- ✅ **VPN functionality** through Firezone control plane
- ✅ **Direct SSH access** for troubleshooting

### After Step 3 (Final):
- ✅ **Private-only gateways** (enhanced security)
- ✅ **No direct internet access** to gateways
- ✅ **VPN still works** through Firezone control plane
- ✅ **Access via Jenkins VM** for management

## 🎯 Why This Approach Works

1. **Avoids Azure dependency issues** by not changing existing public IP attachments
2. **Gets Firezone working first** with the real token
3. **Allows verification** before removing public access
4. **Provides clean transition** to private-only security model

## Current Status: Ready for Step 1

The configuration is now set to deploy successfully with temporary public IPs. After we confirm everything works, we'll remove them for security.

**Ready to deploy Step 1?**
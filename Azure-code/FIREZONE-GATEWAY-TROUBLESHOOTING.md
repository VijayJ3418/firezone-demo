# 🔧 FIREZONE GATEWAY TROUBLESHOOTING

## 🚨 **ISSUE: Gateways Showing "Waiting for connection..."**

Based on the screenshot, your Firezone gateways are not connecting to the admin console. This is a common issue with several possible causes.

## 🔍 **DIAGNOSTIC STEPS:**

### **1. Update Firezone Token**
The token in the screenshot appears to be different from your terraform.tfvars. 

**Copy the FULL token from the Firezone admin console:**
- Go to your Firezone admin console
- Navigate to the Gateway deployment section
- Copy the complete token (it should start with `SFMyNTY.`)
- Update `terraform.tfvars` with the new token

### **2. Check Gateway VM Status**
**SSH into your gateway VMs to check their status:**

```bash
# SSH to primary gateway
ssh azureuser@<primary-gateway-private-ip>

# Check Firezone service status
sudo systemctl status firezone-gateway
sudo docker compose -f /opt/firezone/docker-compose.yml ps
sudo docker compose -f /opt/firezone/docker-compose.yml logs
```

### **3. Common Issues and Fixes:**

#### **A. Token Mismatch**
**Symptoms**: Gateway shows "waiting for connection"
**Fix**: Update token in terraform.tfvars and redeploy

#### **B. Network Connectivity**
**Symptoms**: Gateway can't reach Firezone API
**Check**:
```bash
# Test internet connectivity
curl -I https://api.firezone.dev
ping 8.8.8.8

# Check firewall rules
sudo ufw status
```

#### **C. Docker Issues**
**Symptoms**: Firezone container not running
**Fix**:
```bash
cd /opt/firezone
sudo docker compose down
sudo docker compose pull
sudo docker compose up -d
```

#### **D. Startup Script Issues**
**Check startup logs**:
```bash
sudo tail -f /var/log/firezone-startup.log
sudo journalctl -u firezone-gateway -f
```

## 🚀 **QUICK FIX STEPS:**

### **Step 1: Update Token**
1. Copy the complete token from Firezone admin console
2. Update `Azure-code/terraform.tfvars`:
```hcl
firezone_token = "PASTE_COMPLETE_TOKEN_HERE"
```

### **Step 2: Redeploy Gateways**
```bash
# In Terraform Cloud, run:
terraform apply -target=module.azure_firezone_multi_region
```

### **Step 3: Manual Gateway Restart (if needed)**
**SSH to each gateway VM:**
```bash
cd /opt/firezone
sudo docker compose down
sudo docker compose up -d
```

### **Step 4: Check Connection**
**Wait 2-3 minutes, then check Firezone admin console**

## 🔧 **ALTERNATIVE APPROACH - Manual Gateway Setup:**

If Terraform deployment continues to have issues, you can manually configure the gateways:

### **1. SSH to Gateway VM**
```bash
ssh azureuser@<gateway-private-ip>
```

### **2. Manual Firezone Installation**
```bash
# Stop existing service
sudo systemctl stop firezone-gateway
sudo docker compose -f /opt/firezone/docker-compose.yml down

# Create new configuration
mkdir -p /opt/firezone-manual
cd /opt/firezone-manual

# Download latest gateway configuration
curl -fsSL https://github.com/firezone/firezone/releases/latest/download/gateway.yml -o docker-compose.yml

# Create environment file with new token
cat > .env <<EOF
FIREZONE_TOKEN=YOUR_NEW_TOKEN_HERE
FIREZONE_API_URL=wss://api.firezone.dev
FIREZONE_LOG_LEVEL=info
EOF

# Start gateway
docker compose up -d
```

## 📋 **EXPECTED RESULTS:**

### **After Token Update:**
- ✅ **Gateway Status**: Should change from "Waiting" to "Connected"
- ✅ **Connection Time**: Usually 1-2 minutes after restart
- ✅ **Admin Console**: Shows green "Connected" status

### **If Still Not Working:**
1. **Check VM Internet Access**: Ensure VMs can reach api.firezone.dev
2. **Verify Token**: Make sure token is complete and not truncated
3. **Check Logs**: Review startup and Docker logs for errors
4. **Network Security**: Ensure NSG allows outbound HTTPS (443)

## 🎯 **MOST LIKELY CAUSE:**

**Token mismatch or incomplete token** - This is the #1 cause of "waiting for connection" status.

**Solution**: Copy the COMPLETE token from the screenshot and update terraform.tfvars, then redeploy.

## 📞 **NEED HELP?**

If gateways still don't connect after token update:
1. Share the complete token from Firezone admin console
2. Provide gateway VM logs: `/var/log/firezone-startup.log`
3. Check if VMs have internet connectivity

**The token update should resolve the connectivity issue!** 🚀
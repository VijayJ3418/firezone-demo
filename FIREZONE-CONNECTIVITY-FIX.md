# Firezone Gateway Connectivity Fix

## 🚨 **Issue Identified**
Firezone gateways cannot connect to the control plane due to **no internet access**.

### **Root Cause:**
- Hub Network Security Group had **no outbound rules**
- Firezone subnet had **no NSG association**
- Gateway VMs cannot download packages or reach Firezone API

## 🔧 **Fix Applied**

### **1. Enhanced Hub Network Security Group**
Added comprehensive outbound rules to `vijay-hub-nsg-v6`:

#### **Outbound Rules Added:**
- **HTTPS (443)**: Package downloads, Firezone API, Docker registry
- **HTTP (80)**: Package repositories, redirects
- **DNS (53)**: Domain name resolution
- **NTP (123)**: Time synchronization
- **VNet-to-VNet**: Inter-network communication

#### **Inbound Rules Enhanced:**
- **SSH (22)**: Administrative access
- **WireGuard (51820)**: VPN client connections
- **HTTP (8080)**: Health check endpoint

### **2. NSG Association**
- **Enabled**: NSG association with Firezone subnet
- **Target**: `firezone-subnet` (172.16.3.0/24)
- **Applied to**: Both gateway VMs

## 🚀 **Deployment Steps**

### **Step 1: Apply Terraform Changes**
```bash
# In Terraform Cloud workspace
# Queue plan and apply the changes
```

### **Step 2: Restart Gateway VMs**
After NSG changes are applied:
```bash
# From Azure Portal or CLI
az vm restart --resource-group vijay-networking-global-rg --name vijay-primary-firezone-gateway
az vm restart --resource-group vijay-networking-global-rg --name vijay-secondary-firezone-gateway
```

### **Step 3: Verify Internet Connectivity**
SSH to gateway and test:
```bash
# SSH to primary gateway
ssh azureuser@172.16.3.4

# Test internet connectivity
ping 8.8.8.8
curl -I https://api.firezone.dev
curl -I https://download.docker.com

# Check if startup script can run
sudo tail -f /var/log/firezone-startup.log
```

### **Step 4: Monitor Firezone Status**
Check Firezone admin console:
- **Sites** → Should show "Online Gateways"
- **Resources** → Gateway status should change from "None" to "Connected"

## 📊 **Expected Results**

### **After Fix:**
```
Gateway VM → Internet Access ✅
         → Package Downloads ✅
         → Docker Installation ✅
         → Firezone Container ✅
         → Control Plane Connection ✅
```

### **Firezone Admin Console:**
- **Default Site**: 2 online gateways ✅
- **Azure-Jenkins-Site**: 2 online gateways ✅
- **Gateway Status**: Connected ✅

## 🔍 **Verification Commands**

### **On Gateway VM:**
```bash
# Check Docker is installed and running
sudo docker --version
sudo docker ps

# Check Firezone container
cd /opt/firezone
sudo docker compose ps
sudo docker compose logs

# Test network connectivity
ping 8.8.8.8                    # Internet
ping 172.16.3.5                 # Other gateway
curl https://api.firezone.dev    # Firezone API
```

### **Load Balancer Health:**
```bash
# Check health endpoint
curl http://172.16.3.4:8080
curl http://172.16.3.5:8080
```

## 🎯 **Success Criteria**

### ✅ **Gateway VMs:**
- Internet connectivity restored
- Docker installed and running
- Firezone containers running
- Health check endpoints responding

### ✅ **Firezone Admin Console:**
- Gateways show as "Connected"
- Sites show "Online Gateways"
- VPN clients can connect

### ✅ **Load Balancer:**
- Backend pool shows healthy targets
- Health probes passing
- VPN traffic distributed

## 🚨 **If Issues Persist**

### **Manual Firezone Installation:**
```bash
# SSH to gateway VM
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Create Firezone directory
sudo mkdir -p /opt/firezone
cd /opt/firezone

# Download and configure Firezone
sudo curl -fsSL https://github.com/firezone/firezone/releases/latest/download/gateway.yml -o docker-compose.yml

# Create environment file with your token
sudo tee .env <<EOF
FIREZONE_TOKEN=YOUR_TOKEN_HERE
FIREZONE_API_URL=wss://api.firezone.dev
FIREZONE_LOG_LEVEL=info
EOF

# Start Firezone
sudo docker compose up -d
```

## 📋 **Next Steps**
1. **Apply NSG changes** via Terraform Cloud
2. **Restart gateway VMs** to trigger startup script retry
3. **Monitor Firezone admin console** for gateway connection
4. **Test VPN connectivity** once gateways are online
5. **Deploy Jenkins VM** in Core IT Infrastructure VNet

The fix addresses the fundamental network connectivity issue preventing Firezone gateways from reaching the internet and connecting to the control plane.
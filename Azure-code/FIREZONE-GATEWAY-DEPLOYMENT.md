# Firezone Gateway Deployment Guide - PRIVATE GATEWAYS

## Current Configuration

✅ **Real Firezone Token**: Updated with latest token from admin portal
✅ **Dual Gateway Setup**: Primary and secondary gateways in same region
✅ **Private IPs Only**: No public IPs for enhanced security
✅ **Load Balancer**: Disabled to avoid deployment conflicts
✅ **Automatic Setup**: Startup script handles complete Firezone installation
✅ **Secure Access**: Gateways accessible only via private network

## Deployment Steps

### Step 1: Commit Changes
```powershell
git add .
git commit -m "Configure Firezone gateways with private IPs only - no public access"
git push origin main
```

### Step 2: Deploy via Terraform Cloud
1. **Go to Terraform Cloud workspace**
2. **Start new run** (Queue plan)
3. **Review the plan** - should show:
   - Two Firezone gateway VMs
   - No public IPs (private only)
   - No Load Balancer resources
4. **Apply the changes**

## What Will Be Deployed

### Infrastructure:
- ✅ **Primary Firezone Gateway**: `vijay-primary-firezone-gateway` (private IP only)
- ✅ **Secondary Firezone Gateway**: `vijay-secondary-firezone-gateway` (private IP only)
- ✅ **Private Network**: Gateways in VPN subnet (192.168.131.0/24)
- ✅ **Network Security**: Firewall rules for WireGuard (51820/udp) and SSH
- ✅ **No Public Access**: Enhanced security with private-only deployment

### Automatic Configuration:
- ✅ **Docker Installation**: Latest Docker CE
- ✅ **Firezone Gateway**: Official Firezone gateway container
- ✅ **Real Token**: Configured with your actual Firezone token
- ✅ **WireGuard Setup**: Port 51820 configured and open
- ✅ **Health Checks**: HTTP server on port 8080
- ✅ **Logging**: All setup logs in `/var/log/firezone-startup.log`

## Post-Deployment Access

### Step 1: Access via Jenkins VM
Since gateways are private, access them through the Jenkins VM:

```bash
# SSH to Jenkins VM first (it has public IP)
ssh azureuser@<jenkins-public-ip>

# From Jenkins VM, SSH to Firezone gateways
ssh azureuser@<primary-gateway-private-ip>
ssh azureuser@<secondary-gateway-private-ip>
```

### Step 2: Check Gateway Status
Once connected to a gateway:

```bash
# Check Firezone status
cd /opt/firezone
sudo -u azureuser docker compose ps
sudo -u azureuser docker compose logs

# Check health endpoint
curl http://localhost:8080

# Check startup logs
sudo tail -f /var/log/firezone-startup.log
```

### Step 3: Verify in Firezone Admin Portal
1. **Login to Firezone admin portal**
2. **Go to Gateways section**
3. **Verify both gateways are registered** and showing as "Online"
4. **Check gateway health status**

## VPN Client Configuration

### How Firezone Works with Private Gateways:
1. **Gateways register** with Firezone control plane using the token
2. **Control plane knows** the private IPs of your gateways
3. **VPN clients connect** through the Firezone control plane
4. **Traffic is routed** to the appropriate private gateway

### Client Setup:
1. **Create VPN client** in Firezone admin portal
2. **Download WireGuard config** (will contain proper routing)
3. **Connect using WireGuard client** - Firezone handles the routing to private gateways

## Security Benefits

✅ **No Direct Internet Access**: Gateways not exposed to internet
✅ **Private Network Only**: Access only through established network connections
✅ **Reduced Attack Surface**: No public IPs to target
✅ **Network Segmentation**: Gateways isolated in VPN subnet
✅ **Controlled Access**: Must go through Jenkins VM or established VPN

## Gateway Information

After deployment:

- **Primary Gateway Private IP**: Available in Terraform outputs
- **Secondary Gateway Private IP**: Available in Terraform outputs
- **Access Method**: Via Jenkins VM or established VPN connection
- **SSH Access**: 
  - `ssh azureuser@<jenkins-ip>` then `ssh azureuser@<gateway-private-ip>`
- **Health Checks**: `http://<gateway-private-ip>:8080` (from within network)

## Troubleshooting

### If Gateway Doesn't Start:
```bash
# Access via Jenkins VM first
ssh azureuser@<jenkins-public-ip>
ssh azureuser@<gateway-private-ip>

# Check startup logs
sudo tail -f /var/log/firezone-startup.log

# Check Docker status
sudo systemctl status docker

# Check Firezone container
cd /opt/firezone
sudo -u azureuser docker compose logs -f
```

### If Token Issues:
```bash
# Check environment file
cat /opt/firezone/.env

# Restart Firezone with new token
cd /opt/firezone
sudo -u azureuser docker compose down
sudo -u azureuser docker compose up -d
```

## Architecture

```
Internet
    ↓
Jenkins VM (Public IP)
    ↓
Private Network (192.168.131.0/24)
    ├── Primary Firezone Gateway (Private IP)
    └── Secondary Firezone Gateway (Private IP)
```

This secure deployment ensures Firezone gateways are not directly accessible from the internet while still providing VPN functionality through the Firezone control plane.
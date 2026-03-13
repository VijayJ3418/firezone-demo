# Firezone Gateway Deployment Guide

## Current Configuration

✅ **Real Firezone Token**: Updated with latest token from admin portal
✅ **Dual Gateway Setup**: Primary and secondary gateways in same region
✅ **Public IP Access**: Each gateway has its own public IP for direct access
✅ **Load Balancer**: Disabled to avoid deployment conflicts
✅ **Automatic Setup**: Startup script handles complete Firezone installation

## Deployment Steps

### Step 1: Commit Changes
```powershell
git add .
git commit -m "Simplify Firezone deployment - disable Load Balancer, enable public IPs"
git push origin main
```

### Step 2: Deploy via Terraform Cloud
1. **Go to Terraform Cloud workspace**
2. **Start new run** (Queue plan)
3. **Review the plan** - should show:
   - Two Firezone gateway VMs
   - Two public IPs (one for each gateway)
   - No Load Balancer resources
4. **Apply the changes**

## What Will Be Deployed

### Infrastructure:
- ✅ **Primary Firezone Gateway**: `vijay-primary-firezone-gateway`
- ✅ **Secondary Firezone Gateway**: `vijay-secondary-firezone-gateway`
- ✅ **Public IPs**: Individual public IPs for each gateway
- ✅ **Network Security**: Firewall rules for WireGuard (51820/udp) and SSH

### Automatic Configuration:
- ✅ **Docker Installation**: Latest Docker CE
- ✅ **Firezone Gateway**: Official Firezone gateway container
- ✅ **Real Token**: Configured with your actual Firezone token
- ✅ **WireGuard Setup**: Port 51820 configured and open
- ✅ **Health Checks**: HTTP server on port 8080
- ✅ **Logging**: All setup logs in `/var/log/firezone-startup.log`

## Post-Deployment Verification

### Step 1: Check Gateway Status
SSH to each gateway and verify Firezone is running:

```bash
# SSH to primary gateway
ssh azureuser@<primary-public-ip>

# Check Firezone status
cd /opt/firezone
sudo -u azureuser docker compose ps
sudo -u azureuser docker compose logs

# Check health endpoint
curl http://localhost:8080
```

### Step 2: Verify in Firezone Admin Portal
1. **Login to Firezone admin portal**
2. **Go to Gateways section**
3. **Verify both gateways are registered** and showing as "Online"
4. **Check gateway health status**

### Step 3: Test VPN Connection
1. **Create VPN client** in Firezone admin portal
2. **Download WireGuard config**
3. **Test connection** to either gateway public IP:
   - Primary: `<primary-public-ip>:51820`
   - Secondary: `<secondary-public-ip>:51820`

## Gateway Access Information

After deployment, you'll have:

- **Primary Gateway Public IP**: Available in Terraform outputs
- **Secondary Gateway Public IP**: Available in Terraform outputs
- **WireGuard Endpoints**: 
  - `<primary-ip>:51820`
  - `<secondary-ip>:51820`
- **Health Check URLs**:
  - `http://<primary-ip>:8080`
  - `http://<secondary-ip>:8080`
- **SSH Access**:
  - `ssh azureuser@<primary-ip>`
  - `ssh azureuser@<secondary-ip>`

## Troubleshooting

### If Gateway Doesn't Start:
```bash
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

## Next Steps

1. **Deploy the gateways** using Terraform Cloud
2. **Verify both gateways** are running and registered
3. **Test VPN connectivity** through both endpoints
4. **Optional**: Re-enable Load Balancer later if needed for high availability

This simplified deployment focuses on getting both Firezone gateways running with the real token, avoiding Load Balancer complexity.
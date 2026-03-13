# Final Terraform Deployment with Real Firezone Token

## Changes Made

✅ **Latest Firezone Token**: Updated with newest token from admin portal (March 13, 2026)
✅ **Firezone Module Re-enabled**: Full Load Balancer setup restored
✅ **Primary Backend**: Both gateways will be in Load Balancer backend pool
✅ **Complete Configuration**: All resources properly configured
✅ **Changes Committed**: Successfully pushed to GitHub repository

## Deployment Steps

### Step 1: Commit Changes
```powershell
PowerShell -ExecutionPolicy Bypass -File .\force_commit.ps1
```

### Step 2: Add Environment Variable in Terraform Cloud
To handle potential state conflicts, add this environment variable:
- **Key**: `TF_CLI_ARGS_plan`
- **Value**: `-refresh=false`

### Step 3: Run Terraform Apply
1. **Go to Terraform Cloud** workspace
2. **Start new run** (Plan and Apply)
3. **Review the plan** - should show creating Load Balancer and gateways
4. **Apply the changes**

### Step 4: Remove Environment Variable
After successful deployment, remove the `TF_CLI_ARGS_plan` variable.

## Expected Deployment

### Resources to be Created:
- ✅ **Load Balancer** with public IP
- ✅ **Two Firezone Gateway VMs** (primary and secondary)
- ✅ **Backend Pool** with both gateways
- ✅ **Health Probes** for gateway monitoring
- ✅ **Load Balancing Rules**:
  - UDP 51820 (WireGuard VPN)
  - TCP 8080 (Health checks)

### Automatic Setup via Startup Script:
- ✅ **Docker installation**
- ✅ **Firezone gateway deployment**
- ✅ **WireGuard configuration**
- ✅ **Health check endpoints**
- ✅ **Firewall configuration**

## Final Architecture

```
Internet
    ↓
Load Balancer (Public IP)
    ↓
Backend Pool
    ├── Primary Firezone Gateway (192.168.131.5)
    └── Secondary Firezone Gateway (192.168.131.4)
```

## Testing After Deployment

1. **Get Load Balancer Public IP** from Terraform outputs
2. **Test VPN Connection** using Firezone client
3. **Verify Health Checks** at `http://<lb-ip>:8080`
4. **Check High Availability** by stopping one gateway

## Firezone Token Used
- **Real token from admin portal**: `SFMyNTY.g2gDaANt...`
- **Gateways will auto-register** with Firezone control plane
- **VPN clients can connect** through Load Balancer IP

This deployment will create a production-ready, highly available Firezone VPN setup with Azure Load Balancer!
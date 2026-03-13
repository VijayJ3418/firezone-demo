# Quick Fix Solution for Load Balancer Deployment

## What Happened
- Load Balancer was deleted from Azure but still exists in Terraform state
- This causes a state mismatch error during planning

## Easiest Solution (Recommended)

### Step 1: Commit Current Changes
Run in PowerShell (bypass execution policy):
```powershell
PowerShell -ExecutionPolicy Bypass -File .\force_commit.ps1
```

### Step 2: Clean State in Terraform Cloud
In your Terraform Cloud workspace, go to **Settings** → **Destruction and Deletion** → **Queue destroy plan**

**OR** use targeted state removal:

In Terraform Cloud CLI/Console, run:
```bash
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_backend_address_pool_address.firezone_primary_backend'
```

### Step 3: Deploy Fresh
After state cleanup, run:
```bash
terraform apply
```

## What Will Be Created
- ✅ Load Balancer with public IP (130.131.219.55 or new IP)
- ✅ Backend pool with both Firezone gateways
- ✅ Health probes for gateway monitoring
- ✅ Load balancing rules for WireGuard (UDP 51820) and health checks (TCP 8080)
- ✅ Two Firezone VMs already exist and will be connected to Load Balancer

## Alternative: Destroy and Recreate Everything
If state cleanup is too complex:
1. In Terraform Cloud: **Queue destroy plan** → **Confirm & Apply**
2. After destruction: **Queue plan** → **Confirm & Apply**

This will recreate all infrastructure fresh without state conflicts.

## Expected Final Result
- Hub-spoke network architecture ✅
- Jenkins VM operational ✅
- Load Balancer with dual Firezone gateways for VPN access ✅
- High availability VPN setup complete ✅
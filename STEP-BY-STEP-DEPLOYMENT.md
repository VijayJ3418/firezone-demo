# Step-by-Step Azure Infrastructure Deployment

## Current Issue: VNet Peering Conflicts

The deployment is failing because of orphaned VNet peerings. Here's how to fix it step by step.

## Step 1: Deploy Core Infrastructure Without Peering ✅

**Status**: Ready to deploy
**Action**: The configuration is now set to deploy spoke network without VNet peering

```terraform
enable_hub_peering = false  # Temporarily disabled
```

This will create:
- ✅ Spoke VNet (`vijay-vpc-spoke`)
- ✅ Jenkins subnet
- ✅ Application Gateway subnet  
- ✅ VPN subnet (`subnet-vpn-v4`)
- ✅ Network Security Groups
- ✅ Private DNS zone

**Run**: `terraform apply` in Terraform Cloud

## Step 2: Clean Up Orphaned Peerings

After Step 1 completes, manually clean up the orphaned peering:

### Option A: Azure Portal (Recommended)
1. Go to Azure Portal → Virtual Networks
2. Navigate to `vijay-vpc-hub` 
3. Go to Peerings section
4. Delete the orphaned peering: `hub-to-spoke-peering`

### Option B: Azure CLI
```bash
az network vnet peering delete \
  --resource-group vijay-networking-global-rg \
  --vnet-name vijay-vpc-hub \
  --name hub-to-spoke-peering
```

## Step 3: Enable VNet Peering

After cleaning up orphaned peerings, update the configuration:

```terraform
enable_hub_peering = true  # Re-enable peering
```

**Run**: `terraform apply` again

This will create:
- ✅ `spoke-to-hub-peering-v4`
- ✅ `hub-to-spoke-peering-v4`

## Step 4: Enable Jenkins VM

After networking is stable, uncomment the Jenkins VM module in `main.tf`:

```terraform
module "azure_jenkins_vm" {
  source = "./azure-jenkins-vm"
  # ... configuration
}
```

## Step 5: Enable Firezone Multi-Region

Finally, enable the Firezone modules for multi-region VPN setup.

## Alternative: Clean Slate Approach

If the step-by-step approach is too complex, you can:

1. **Destroy everything**: `terraform destroy`
2. **Deploy fresh**: `terraform apply`

This ensures no orphaned resources cause conflicts.

## Current Configuration Status

- 🟢 Hub network: Deployed and stable
- 🟡 Spoke network: Ready (peering disabled temporarily)
- 🔴 Jenkins VM: Disabled
- 🔴 Firezone: Disabled

## Next Action Required

Run `terraform apply` to deploy the spoke network without peering conflicts.
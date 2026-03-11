# Azure Infrastructure Cleanup and Redeploy Guide

## Current Issue
You have conflicting Azure resources from previous deployments that are causing Terraform to fail. The cleanest solution is to destroy and recreate the infrastructure.

## Option 1: Clean Destroy and Redeploy (Recommended)

### Step 1: Destroy All Resources
In Terraform Cloud, run:
```
terraform destroy
```
This will remove all Azure resources and clean the state.

### Step 2: Redeploy with Fixed Configuration
After destroy completes, run:
```
terraform apply
```

## Option 2: Manual Resource Cleanup (If destroy fails)

If terraform destroy fails, you can manually delete the Azure resource groups:

1. Go to Azure Portal
2. Delete these resource groups:
   - `vijay-networking-global-rg`
   - `vijay-core-infrastructure-rg`
3. Wait for deletion to complete
4. Run `terraform apply` to create fresh resources

## Option 3: Import Existing Resources (Advanced)

If you want to keep existing resources, you can import them:

```bash
# Import existing subnet
terraform import module.azure_core_infrastructure.azurerm_subnet.subnet_vpn /subscriptions/95fe2b5a-17cb-4b4c-b5ca-36c90e4dfefd/resourceGroups/vijay-core-infrastructure-rg/providers/Microsoft.Network/virtualNetworks/vijay-vpc-spoke/subnets/subnet-vpn-v2

# Import existing peering
terraform import module.azure_core_infrastructure.azurerm_virtual_network_peering.hub_to_spoke[0] /subscriptions/95fe2b5a-17cb-4b4c-b5ca-36c90e4dfefd/resourceGroups/vijay-networking-global-rg/providers/Microsoft.Network/virtualNetworks/vijay-vpc-hub/virtualNetworkPeerings/hub-to-spoke-peering
```

## Changes Made to Fix Conflicts

1. **Updated CIDR ranges**:
   - VPN subnet: `192.168.130.0/24` → `192.168.131.0/24`

2. **Updated resource names**:
   - Subnet: `subnet-vpn-v3` → `subnet-vpn-v4`
   - Peering: `hub-to-spoke-peering-v3` → `hub-to-spoke-peering-v4`
   - Spoke peering: `spoke-to-hub-peering` → `spoke-to-hub-peering-v4`

## Recommended Next Steps

1. **Choose Option 1** (destroy and redeploy) for the cleanest solution
2. After successful deployment, enable Jenkins VM module
3. Then enable Firezone multi-region module
4. Test the complete infrastructure

## Current Configuration Status

✅ Hub network module - Ready
✅ Spoke network module - Ready (with conflict fixes)
⏸️ Jenkins VM module - Disabled (ready to enable)
⏸️ Firezone modules - Disabled (ready to enable)
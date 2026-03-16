# Terraform State Cleanup and Resource Import Guide

## Current Issues
1. Public IP `vijay-firezone-lb-pip` exists in Azure but not in Terraform state
2. Resource Group `vijay-core-infrastructure-secondary-rg` exists in Azure but not in Terraform state
3. Previous Firezone VMs were destroyed but some state references remain

## Solution Steps

### Step 1: Import Existing Resources (Run in Terraform Cloud)

```bash
# Import the existing public IP
terraform import 'module.azure_firezone_multi_region[0].azurerm_public_ip.firezone_lb_pip' '/subscriptions/95fe2b5a-17cb-4b4c-b5ca-36c90e4dfefd/resourceGroups/vijay-core-infrastructure-rg/providers/Microsoft.Network/publicIPAddresses/vijay-firezone-lb-pip'

# Import the existing secondary resource group (if it still exists and is needed)
# terraform import 'module.azure_core_infrastructure_secondary[0].azurerm_resource_group.core_infrastructure_secondary' '/subscriptions/95fe2b5a-17cb-4b4c-b5ca-36c90e4dfefd/resourceGroups/vijay-core-infrastructure-secondary-rg'
```

### Step 2: Alternative - Delete Existing Resources (if import fails)

If import doesn't work, delete the existing resources from Azure Portal:
1. Delete `vijay-firezone-lb-pip` public IP
2. Delete `vijay-core-infrastructure-secondary-rg` resource group (if not needed)

### Step 3: Clean Deployment

After handling the existing resources, run:
```bash
terraform plan
terraform apply
```

## Current Configuration Status
- ✅ Secondary infrastructure module disabled (commented out)
- ✅ Firezone multi-region enabled with Load Balancer
- ✅ Both gateways deploy in same region/VNet for Load Balancer compatibility
- ✅ Backend resource renamed to avoid state conflicts
- ✅ Public IP lifecycle rules added to handle existing resource

## Expected Resources After Deployment
- Load Balancer with public IP
- Two Firezone gateway VMs in same subnet
- Backend pool with both gateways
- Health probes and load balancing rules
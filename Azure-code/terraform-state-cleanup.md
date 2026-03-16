# Terraform State Cleanup Instructions

## Current Situation
- Load Balancer and related resources were deleted from Azure
- Terraform state still has references to these deleted resources
- Need to clean up state before proceeding

## Solution: Remove Orphaned Resources from State

In Terraform Cloud, run these commands to remove the orphaned resources from state:

### 1. Remove Load Balancer Components
```bash
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb.firezone_lb'
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_backend_address_pool.firezone_backend_pool'
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_probe.firezone_health_probe'
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_rule.firezone_wireguard_rule'
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_rule.firezone_health_rule'
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_backend_address_pool_address.firezone_primary_backend'
terraform state rm 'module.azure_firezone_multi_region[0].azurerm_lb_backend_address_pool_address.firezone_secondary_backend'
```

### 2. Remove Secondary Infrastructure (if exists)
```bash
terraform state rm 'module.azure_core_infrastructure_secondary[0].azurerm_virtual_network_peering.primary_to_secondary[0]'
```

### 3. After State Cleanup, Run Apply
```bash
terraform plan
terraform apply
```

## Alternative: Targeted Apply (Easier)

Instead of manual state cleanup, you can use targeted apply to recreate just the Load Balancer:

```bash
terraform apply -target='module.azure_firezone_multi_region[0].azurerm_public_ip.firezone_lb_pip'
terraform apply -target='module.azure_firezone_multi_region[0].azurerm_lb.firezone_lb'
terraform apply -target='module.azure_firezone_multi_region[0].azurerm_lb_backend_address_pool.firezone_backend_pool'
terraform apply
```

## Expected Result
After cleanup and apply:
- ✅ New Load Balancer created
- ✅ Public IP for Load Balancer
- ✅ Backend pool with both Firezone gateways
- ✅ Health probes and load balancing rules
- ✅ Both Firezone VMs connected to Load Balancer
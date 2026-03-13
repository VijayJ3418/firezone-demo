# Final Solution: Skip Refresh and Force Apply

## The Issue
Terraform state contains references to deleted Load Balancer resources, causing refresh to fail during planning.

## Solution: Use -refresh=false Flag

In Terraform Cloud, add this environment variable to skip the problematic refresh:

### Environment Variable to Add:
- **Key**: `TF_CLI_ARGS_plan`
- **Value**: `-refresh=false`

### Alternative: Use -replace Flag
If the above doesn't work, try:
- **Key**: `TF_CLI_ARGS_apply`  
- **Value**: `-refresh=false -replace=module.azure_firezone_multi_region[0].azurerm_lb_backend_address_pool_address.firezone_primary_backend`

## Steps:
1. **Add the environment variable** in Terraform Cloud Variables tab
2. **Run Plan and Apply** - this will skip the problematic refresh
3. **The destroy should succeed** - removing all Firezone resources
4. **Remove the environment variable** after successful destroy
5. **Re-enable Firezone module** and deploy fresh

## Expected Result:
- ✅ All Firezone resources destroyed (7 resources)
- ✅ Orphaned peering removed (1 resource)  
- ✅ Jenkins VM and networking preserved
- ✅ Clean state for fresh Firezone deployment

## After Successful Destroy:
1. Remove the `-refresh=false` environment variable
2. Uncomment the Firezone module in main.tf
3. Deploy fresh Firezone infrastructure with Load Balancer
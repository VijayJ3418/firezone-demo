# Azure Free Trial Compatible VM Sizes

If you encounter quota restrictions, try these VM sizes in order of preference:

## Recommended VM Sizes for Free Trial (in order):

1. **Standard_B1ms** (1 vCPU, 2 GB RAM) - Currently configured
   - Best balance of performance and availability
   - Burstable performance for Jenkins workloads

2. **Standard_B1s** (1 vCPU, 1 GB RAM)
   - Minimal resources but usually available
   - May be slow for Jenkins but functional

3. **Standard_A1_v2** (1 vCPU, 2 GB RAM)
   - Alternative to B-series
   - Sometimes available when B-series is not

4. **Standard_D1_v2** (1 vCPU, 3.5 GB RAM)
   - More memory, good for Jenkins
   - May have quota restrictions

## How to Change VM Size in Terraform Cloud:

1. Go to your Terraform Cloud workspace
2. Navigate to Variables
3. Find the `jenkins_vm_size` variable
4. Update the value to one of the sizes above
5. Save and run a new plan/apply

## Alternative Regions to Try:

If East US has quota issues, try these regions:
- Central US
- South Central US
- West US 2
- North Central US

**Note**: If you change regions, you'll need to update the `location` variable as well.
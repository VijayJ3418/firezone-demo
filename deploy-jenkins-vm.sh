#!/bin/bash

# Jenkins VM Deployment Script with Multiple VM Size Fallbacks
# This script tries different VM sizes until one succeeds

echo "🚀 Starting Jenkins VM deployment with fallback VM sizes..."

# Array of VM sizes to try (in order of preference for free trial)
VM_SIZES=(
    "Standard_A1"
    "Standard_A0" 
    "Standard_D1_v2"
    "Standard_F1s"
    "Standard_B1ls"
    "Standard_B1s"
)

# Array of regions to try
REGIONS=(
    "East US"
    "South Central US"
    "West US"
    "North Central US"
    "West US 2"
)

# Function to try deploying with a specific VM size and region
try_deploy() {
    local vm_size=$1
    local region=$2
    
    echo "🔄 Trying VM size: $vm_size in region: $region"
    
    # Update terraform.tfvars or use -var flags
    terraform apply \
        -target=module.azure_jenkins_vm \
        -var="jenkins_vm_size=$vm_size" \
        -var="location=$region" \
        -auto-approve
    
    return $?
}

# Try each VM size in the current region first
echo "📍 Trying VM sizes in current region (East US)..."
for vm_size in "${VM_SIZES[@]}"; do
    echo "🔄 Attempting deployment with $vm_size..."
    
    if try_deploy "$vm_size" "East US"; then
        echo "✅ SUCCESS! Jenkins VM deployed with $vm_size in East US"
        echo "🎉 Deployment completed successfully!"
        
        # Show VM information
        echo "📋 VM Information:"
        terraform output jenkins_vm
        exit 0
    else
        echo "❌ Failed with $vm_size in East US"
    fi
done

# If all VM sizes failed in East US, try other regions with Standard_A1
echo "🌍 Trying Standard_A1 in other regions..."
for region in "${REGIONS[@]:1}"; do  # Skip East US as we already tried it
    echo "🔄 Attempting deployment with Standard_A1 in $region..."
    
    if try_deploy "Standard_A1" "$region"; then
        echo "✅ SUCCESS! Jenkins VM deployed with Standard_A1 in $region"
        echo "🎉 Deployment completed successfully!"
        
        # Show VM information
        echo "📋 VM Information:"
        terraform output jenkins_vm
        exit 0
    else
        echo "❌ Failed with Standard_A1 in $region"
    fi
done

# If everything failed
echo "💥 DEPLOYMENT FAILED!"
echo "❌ All VM sizes and regions failed. This might be due to:"
echo "   1. Free trial quota limitations"
echo "   2. Regional capacity issues"
echo "   3. Subscription restrictions"
echo ""
echo "🔧 Recommended actions:"
echo "   1. Contact Azure support for quota increase"
echo "   2. Try deploying at a different time (off-peak hours)"
echo "   3. Consider using Azure Container Instances instead"
echo "   4. Try a different Azure subscription"

exit 1
#!/bin/bash

# Script to try different VM sizes for Jenkins deployment
echo "🚀 Trying different VM sizes for Jenkins deployment..."

# Remove any failed VM resource from state
echo "🧹 Cleaning up failed VM resource from Terraform state..."
terraform state rm module.azure_jenkins_vm.azurerm_linux_virtual_machine.jenkins_vm 2>/dev/null || true

# Array of VM sizes to try (in order of likelihood to work in free trial)
VM_SIZES=(
    "Standard_A1"      # 1 vCPU, 1.75 GB RAM - Most likely to work
    "Standard_A0"      # 1 vCPU, 0.75 GB RAM - Minimal but available
    "Standard_B1ls"    # 1 vCPU, 0.5 GB RAM  - Burstable, often available
    "Standard_F1s"     # 1 vCPU, 2 GB RAM    - Compute optimized
    "Standard_D1_v2"   # 1 vCPU, 3.5 GB RAM  - General purpose
)

# Try each VM size
for vm_size in "${VM_SIZES[@]}"; do
    echo ""
    echo "🔄 Attempting deployment with VM size: $vm_size"
    echo "⏰ $(date)"
    
    # Try to deploy with current VM size
    if terraform apply -target=module.azure_jenkins_vm \
        -var="jenkins_vm_size=$vm_size" \
        -var="location=East US" \
        -auto-approve; then
        
        echo ""
        echo "✅ SUCCESS! Jenkins VM deployed successfully!"
        echo "🎉 VM Size: $vm_size"
        echo "📍 Location: East US"
        echo "⏰ Completed at: $(date)"
        
        # Show the VM information
        echo ""
        echo "📋 VM Information:"
        terraform output jenkins_vm 2>/dev/null || echo "Output not available yet"
        
        echo ""
        echo "🔗 Next steps:"
        echo "1. Wait 5-10 minutes for Jenkins to install"
        echo "2. SSH to the VM to check Jenkins status"
        echo "3. Access Jenkins at http://<private-ip>:8080"
        
        exit 0
    else
        echo "❌ Failed with $vm_size"
        echo "🧹 Cleaning up failed resource..."
        terraform state rm module.azure_jenkins_vm.azurerm_linux_virtual_machine.jenkins_vm 2>/dev/null || true
    fi
done

echo ""
echo "💥 All VM sizes failed!"
echo "❌ This indicates severe quota or capacity restrictions on your free trial account."
echo ""
echo "🔧 Recommended actions:"
echo "1. Contact Azure support for quota increase"
echo "2. Try a different Azure region:"
echo "   - South Central US"
echo "   - West US"
echo "   - North Central US"
echo "3. Try deploying at off-peak hours (early morning/late evening)"
echo "4. Consider using Azure Container Instances instead of VMs"
echo ""
echo "📞 Azure Support: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade"

exit 1
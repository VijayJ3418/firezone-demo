#!/bin/bash

# Standalone Jenkins Deployment Script
# Simplified approach without hub network complexity

echo "🚀 Starting Standalone Jenkins Deployment..."
echo "📅 $(date)"
echo ""

# Clean up any existing state issues
echo "🧹 Cleaning up Terraform state..."
terraform state rm module.azure_networking_global.azurerm_virtual_network.vpc_hub 2>/dev/null || true
terraform state rm module.azure_networking_global.azurerm_resource_group.networking_global 2>/dev/null || true

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
if ! terraform validate; then
    echo "❌ Terraform validation failed!"
    exit 1
fi

echo ""
echo "📋 Deployment Plan:"
echo "1. Core Infrastructure (VNet, Subnets, NSGs, DNS)"
echo "2. Jenkins VM with multiple size fallbacks"
echo ""

# Deploy core infrastructure first
echo "🏗️  Step 1: Deploying Core Infrastructure..."
if terraform apply -target=module.azure_core_infrastructure -auto-approve; then
    echo "✅ Core infrastructure deployed successfully!"
else
    echo "❌ Core infrastructure deployment failed!"
    exit 1
fi

echo ""
echo "🖥️  Step 2: Deploying Jenkins VM..."

# Array of VM sizes to try
VM_SIZES=(
    "Standard_A1"      # 1 vCPU, 1.75 GB RAM - Most likely to work
    "Standard_A0"      # 1 vCPU, 0.75 GB RAM - Minimal but available
    "Standard_B1ls"    # 1 vCPU, 0.5 GB RAM  - Burstable
    "Standard_F1s"     # 1 vCPU, 2 GB RAM    - Compute optimized
    "Standard_D1_v2"   # 1 vCPU, 3.5 GB RAM  - General purpose
)

# Try each VM size
for vm_size in "${VM_SIZES[@]}"; do
    echo ""
    echo "🔄 Trying VM size: $vm_size"
    
    if terraform apply -target=module.azure_jenkins_vm \
        -var="jenkins_vm_size=$vm_size" \
        -auto-approve; then
        
        echo ""
        echo "🎉 SUCCESS! Jenkins VM deployed successfully!"
        echo "📊 VM Size: $vm_size"
        echo "📍 Location: East US"
        echo "⏰ Completed: $(date)"
        
        # Show deployment summary
        echo ""
        echo "📋 Deployment Summary:"
        echo "✅ Resource Group: vijay-core-infrastructure-rg"
        echo "✅ VNet: vijay-vpc-spoke (192.168.0.0/16)"
        echo "✅ Jenkins Subnet: subnet-jenkins (192.168.0.0/24)"
        echo "✅ Jenkins VM: jenkins-server ($vm_size)"
        echo "✅ DNS Zone: dglearn.online"
        
        # Get VM IP address
        echo ""
        echo "🔍 Getting VM Information..."
        VM_IP=$(terraform output -json jenkins_vm 2>/dev/null | jq -r '.jenkins_vm.private_ip_address' 2>/dev/null || echo "Not available")
        
        if [ "$VM_IP" != "Not available" ] && [ "$VM_IP" != "null" ]; then
            echo "🌐 Jenkins Private IP: $VM_IP"
            echo "🔗 Jenkins URL: http://$VM_IP:8080"
            echo "🔑 SSH Command: ssh azureuser@$VM_IP"
        fi
        
        echo ""
        echo "⏳ Next Steps:"
        echo "1. Wait 5-10 minutes for Jenkins installation to complete"
        echo "2. SSH to the VM to check Jenkins status:"
        echo "   ssh azureuser@$VM_IP"
        echo "3. Check Jenkins service:"
        echo "   sudo systemctl status jenkins"
        echo "4. Get initial admin password:"
        echo "   sudo cat /jenkins/jenkins_home/secrets/initialAdminPassword"
        echo "5. Access Jenkins web interface at http://$VM_IP:8080"
        
        exit 0
    else
        echo "❌ Failed with $vm_size"
        # Clean up failed VM resource
        terraform state rm module.azure_jenkins_vm.azurerm_linux_virtual_machine.jenkins_vm 2>/dev/null || true
    fi
done

echo ""
echo "💥 All VM sizes failed!"
echo "❌ Your free trial account has severe quota restrictions."
echo ""
echo "🔧 Recommended Actions:"
echo "1. Contact Azure Support for quota increase"
echo "2. Try different regions (South Central US, West US)"
echo "3. Try deploying during off-peak hours"
echo "4. Consider Azure Container Instances instead"
echo ""
echo "📞 Azure Support: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade"

exit 1
#!/bin/bash

# Azure Jenkins Infrastructure Deployment - Original Exercise Requirements
# Hub-Spoke Architecture with Jenkins VM

echo "🚀 Azure Jenkins Infrastructure Deployment"
echo "=========================================="
echo "📋 Exercise Requirements:"
echo "   ✅ Hub Network (172.16.0.0/16)"
echo "   ✅ Spoke Network (192.168.0.0/16)"
echo "   ✅ VNet Peering (Hub ↔ Spoke)"
echo "   ✅ Jenkins VM with multiple size fallbacks"
echo "   ✅ Private DNS Zone"
echo "   ✅ Network Security Groups"
echo ""
echo "📅 Started: $(date)"
echo ""

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating configuration..."
if ! terraform validate; then
    echo "❌ Terraform validation failed!"
    exit 1
fi

echo ""
echo "🏗️  PHASE 1: Deploying Hub Network..."
echo "======================================"
if terraform apply -target=module.azure_networking_global -auto-approve; then
    echo "✅ Hub network deployed successfully!"
    echo "   📍 Resource Group: vijay-networking-global-rg"
    echo "   🌐 VNet: vijay-vpc-hub (172.16.0.0/16)"
    echo "   🔒 NSG: vijay-hub-nsg-v5"
else
    echo "❌ Hub network deployment failed!"
    exit 1
fi

echo ""
echo "🏗️  PHASE 2: Deploying Spoke Network with Peering..."
echo "=================================================="
if terraform apply -target=module.azure_core_infrastructure -auto-approve; then
    echo "✅ Spoke network deployed successfully!"
    echo "   📍 Resource Group: vijay-core-infrastructure-rg"
    echo "   🌐 VNet: vijay-vpc-spoke (192.168.0.0/16)"
    echo "   🔗 VNet Peering: Hub ↔ Spoke"
    echo "   🏷️  DNS Zone: dglearn.online"
else
    echo "❌ Spoke network deployment failed!"
    exit 1
fi

echo ""
echo "🖥️  PHASE 3: Deploying Jenkins VM..."
echo "=================================="

# Array of VM sizes to try (free trial optimized)
VM_SIZES=(
    "Standard_A1"      # 1 vCPU, 1.75 GB RAM - Best for free trial
    "Standard_A0"      # 1 vCPU, 0.75 GB RAM - Minimal but works
    "Standard_B1ls"    # 1 vCPU, 0.5 GB RAM  - Burstable
    "Standard_F1s"     # 1 vCPU, 2 GB RAM    - Compute optimized
    "Standard_D1_v2"   # 1 vCPU, 3.5 GB RAM  - General purpose
)

# Try each VM size
for vm_size in "${VM_SIZES[@]}"; do
    echo ""
    echo "🔄 Attempting Jenkins VM deployment with: $vm_size"
    
    if terraform apply -target=module.azure_jenkins_vm \
        -var="jenkins_vm_size=$vm_size" \
        -auto-approve; then
        
        echo ""
        echo "🎉 SUCCESS! Complete infrastructure deployed!"
        echo "============================================"
        echo "📊 VM Size: $vm_size"
        echo "📍 Location: East US"
        echo "⏰ Completed: $(date)"
        
        # Show deployment summary
        echo ""
        echo "📋 DEPLOYMENT SUMMARY:"
        echo "====================="
        echo "✅ Hub Network:"
        echo "   - Resource Group: vijay-networking-global-rg"
        echo "   - VNet: vijay-vpc-hub (172.16.0.0/16)"
        echo "   - Subnet: subnet-vpn (172.16.0.0/24)"
        echo ""
        echo "✅ Spoke Network:"
        echo "   - Resource Group: vijay-core-infrastructure-rg"
        echo "   - VNet: vijay-vpc-spoke (192.168.0.0/16)"
        echo "   - Jenkins Subnet: subnet-jenkins (192.168.0.0/24)"
        echo "   - AppGW Subnet: subnet-appgw (192.168.128.0/23)"
        echo "   - VPN Subnet: subnet-vpn-v4 (192.168.131.0/24)"
        echo ""
        echo "✅ VNet Peering: Hub ↔ Spoke"
        echo "✅ DNS Zone: dglearn.online"
        echo "✅ Jenkins VM: jenkins-server ($vm_size)"
        
        # Get VM information
        echo ""
        echo "🔍 Getting VM Information..."
        VM_IP=$(terraform output -json jenkins_vm 2>/dev/null | jq -r '.jenkins_vm.private_ip_address' 2>/dev/null || echo "Not available")
        
        if [ "$VM_IP" != "Not available" ] && [ "$VM_IP" != "null" ]; then
            echo "🌐 Jenkins Private IP: $VM_IP"
            echo "🔗 Jenkins URL: http://$VM_IP:8080"
            echo "🔑 SSH Command: ssh azureuser@$VM_IP"
        fi
        
        echo ""
        echo "💰 ESTIMATED MONTHLY COST:"
        echo "========================="
        echo "   VM ($vm_size): ₹1,000-1,500"
        echo "   Storage: ₹300-500"
        echo "   Networking: ₹200-400"
        echo "   Total: ₹1,500-2,400/month"
        
        echo ""
        echo "⏳ NEXT STEPS:"
        echo "============="
        echo "1. Wait 5-10 minutes for Jenkins installation"
        echo "2. SSH to Jenkins VM:"
        echo "   ssh azureuser@$VM_IP"
        echo "3. Check Jenkins status:"
        echo "   sudo systemctl status jenkins"
        echo "4. Get initial admin password:"
        echo "   sudo cat /jenkins/jenkins_home/secrets/initialAdminPassword"
        echo "5. Access Jenkins: http://$VM_IP:8080"
        echo ""
        echo "🎯 EXERCISE COMPLETED SUCCESSFULLY!"
        echo "   Hub-Spoke architecture with Jenkins VM deployed as required."
        
        exit 0
    else
        echo "❌ Failed with $vm_size"
        # Clean up failed VM resource
        terraform state rm module.azure_jenkins_vm.azurerm_linux_virtual_machine.jenkins_vm 2>/dev/null || true
    fi
done

echo ""
echo "💥 JENKINS VM DEPLOYMENT FAILED!"
echo "==============================="
echo "❌ All VM sizes failed. This indicates quota restrictions."
echo ""
echo "🔧 RECOMMENDED ACTIONS:"
echo "1. Contact Azure Support for quota increase"
echo "2. Try different regions (South Central US, West US)"
echo "3. Try deploying during off-peak hours"
echo "4. Consider using smaller VM sizes manually"
echo ""
echo "📞 Azure Support: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade"
echo ""
echo "✅ NOTE: Hub and Spoke networks are deployed successfully!"
echo "   Only the Jenkins VM failed due to quota restrictions."

exit 1
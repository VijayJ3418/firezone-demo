#!/bin/bash

# Azure Jenkins Infrastructure Deployment - Exercise Requirements
# Hub-Spoke Architecture with Jenkins VM

echo "🚀 Azure Jenkins Infrastructure Deployment"
echo "=========================================="
echo "📋 Exercise: Hub-Spoke Architecture with Jenkins VM"
echo "📅 Started: $(date)"
echo ""

# Initialize and validate
terraform init
terraform validate

echo "🏗️  Phase 1: Hub Network..."
terraform apply -target=module.azure_networking_global -auto-approve

echo "🏗️  Phase 2: Spoke Network with Peering..."
terraform apply -target=module.azure_core_infrastructure -auto-approve

echo "🖥️  Phase 3: Jenkins VM..."
# Try different VM sizes for free trial compatibility
VM_SIZES=("Standard_A1" "Standard_A0" "Standard_B1ls" "Standard_F1s")

for vm_size in "${VM_SIZES[@]}"; do
    echo "🔄 Trying VM size: $vm_size"
    if terraform apply -target=module.azure_jenkins_vm -var="jenkins_vm_size=$vm_size" -auto-approve; then
        echo "✅ SUCCESS! Infrastructure deployed with $vm_size"
        terraform output
        exit 0
    else
        terraform state rm module.azure_jenkins_vm.azurerm_linux_virtual_machine.jenkins_vm 2>/dev/null || true
    fi
done

echo "❌ All VM sizes failed - check Azure quotas"
exit 1
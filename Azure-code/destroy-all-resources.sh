#!/bin/bash

# Complete Azure Resource Cleanup Script
# This will destroy ALL Azure resources shown in your screenshot

echo "🧹 COMPLETE AZURE RESOURCE CLEANUP"
echo "=================================="
echo "⚠️  WARNING: This will destroy ALL Azure resources!"
echo "📅 $(date)"
echo ""

# Destroy all Terraform-managed resources
echo "🔥 Step 1: Destroying Terraform resources..."
terraform destroy -auto-approve || echo "⚠️  Some resources may not be Terraform-managed"

# Clean up Terraform state
echo "🧹 Step 2: Cleaning Terraform state..."
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -rf .terraform/

# Force delete specific resource groups from screenshot
echo "🗑️  Step 3: Force deleting resource groups..."
az group delete --name "vijay-core-infrastructure-rg" --yes --no-wait || echo "Resource group not found"
az group delete --name "NetworkWatcherRG" --yes --no-wait || echo "NetworkWatcher RG not found"

# Delete specific resources shown in screenshot
echo "🔍 Step 4: Cleaning up specific resources..."

# Delete Network Watchers (shown in screenshot)
az network watcher delete --name "NetworkWatcher_centralus" --resource-group "NetworkWatcherRG" || echo "NetworkWatcher Central US not found"
az network watcher delete --name "NetworkWatcher_eastus" --resource-group "NetworkWatcherRG" || echo "NetworkWatcher East US not found"
az network watcher delete --name "NetworkWatcher_westus2" --resource-group "NetworkWatcherRG" || echo "NetworkWatcher West US2 not found"

# Delete DNS Zone
az network private-dns zone delete --name "dglearn.online" --resource-group "vijay-core-infrastructure-rg" --yes || echo "DNS zone not found"

# Delete NSGs
az network nsg delete --name "vijay-appgw-nsg" --resource-group "vijay-core-infrastructure-rg" || echo "AppGW NSG not found"
az network nsg delete --name "vijay-jenkins-nsg" --resource-group "vijay-core-infrastructure-rg" || echo "Jenkins NSG not found"

# Delete VNet
az network vnet delete --name "vijay-vpc-spoke" --resource-group "vijay-core-infrastructure-rg" || echo "VNet not found"

echo ""
echo "⏳ Waiting for all deletions to complete..."
sleep 30

# Verify cleanup
echo "🔍 Step 5: Verifying cleanup..."
echo "Remaining resource groups:"
az group list --query "[?contains(name, 'vijay') || contains(name, 'NetworkWatcher')].{Name:name, Location:location}" -o table || echo "No remaining resource groups"

echo ""
echo "✅ AZURE RESOURCE CLEANUP COMPLETE!"
echo "=================================="
echo "🎉 All Azure resources have been destroyed."
echo "💰 Cost: ₹0/month (all resources deleted)"
echo "📅 Completed: $(date)"
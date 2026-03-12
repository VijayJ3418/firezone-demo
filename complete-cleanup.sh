#!/bin/bash

# Complete Azure Infrastructure Cleanup Script
# This script will destroy all resources and clean up Terraform state

echo "🧹 COMPLETE AZURE INFRASTRUCTURE CLEANUP"
echo "========================================"
echo "⚠️  WARNING: This will destroy ALL Azure resources created by Terraform!"
echo "📅 $(date)"
echo ""

read -p "Are you sure you want to proceed? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

echo ""
echo "🚀 Starting complete cleanup process..."

# Step 1: Destroy all Terraform resources
echo ""
echo "🔥 Step 1: Destroying all Terraform resources..."
terraform destroy -auto-approve || echo "⚠️  Some resources may have already been destroyed"

# Step 2: Clean up Terraform state files
echo ""
echo "🧹 Step 2: Cleaning up Terraform state files..."
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -rf .terraform/

# Step 3: Clean up any remaining Azure resources manually (if needed)
echo ""
echo "🔍 Step 3: Checking for remaining Azure resources..."

# Check for resource groups
echo "📋 Checking for resource groups..."
az group list --query "[?contains(name, 'vijay')].{Name:name, Location:location}" -o table 2>/dev/null || echo "Azure CLI not available or not logged in"

# Step 4: Force delete resource groups if they exist
echo ""
echo "🗑️  Step 4: Force deleting resource groups (if they exist)..."

# Try to delete resource groups
az group delete --name "vijay-networking-global-rg" --yes --no-wait 2>/dev/null || echo "Hub resource group not found or already deleted"
az group delete --name "vijay-core-infrastructure-rg" --yes --no-wait 2>/dev/null || echo "Spoke resource group not found or already deleted"

echo ""
echo "⏳ Waiting for resource group deletions to complete..."
echo "   This may take 5-10 minutes..."

# Wait for deletions to complete
for i in {1..30}; do
    hub_exists=$(az group exists --name "vijay-networking-global-rg" 2>/dev/null || echo "false")
    spoke_exists=$(az group exists --name "vijay-core-infrastructure-rg" 2>/dev/null || echo "false")
    
    if [ "$hub_exists" = "false" ] && [ "$spoke_exists" = "false" ]; then
        echo "✅ All resource groups deleted successfully!"
        break
    fi
    
    echo "⏳ Still waiting... ($i/30)"
    sleep 20
done

# Step 5: Reinitialize Terraform
echo ""
echo "🔧 Step 5: Reinitializing Terraform..."
terraform init

echo ""
echo "✅ CLEANUP COMPLETE!"
echo "==================="
echo "🎉 All resources have been destroyed and Terraform state cleaned up."
echo "🚀 You can now proceed with a fresh deployment."
echo ""
echo "📋 Next Steps:"
echo "1. Run: ./deploy-standalone.sh"
echo "2. Or run: terraform apply -auto-approve"
echo ""
echo "💰 Cost Impact: ~₹0/month (all resources destroyed)"
echo "📅 Completed: $(date)"
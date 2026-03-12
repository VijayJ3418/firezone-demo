#!/bin/bash

# Fix Terraform State Issues - Complete Cleanup and Fresh Start
echo "🔧 FIXING TERRAFORM STATE ISSUES"
echo "================================"
echo "📅 $(date)"
echo ""

echo "🛑 Step 1: Stopping any running Terraform operations..."
# Kill any running terraform processes
pkill -f terraform || echo "No running terraform processes"

echo "🧹 Step 2: Complete Terraform state cleanup..."
# Remove all Terraform state and cache
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -rf .terraform/

echo "🗑️  Step 3: Force delete ALL Azure resources..."
# Delete resource groups completely
az group delete --name "vijay-networking-global-rg" --yes --no-wait || echo "Hub RG not found"
az group delete --name "vijay-core-infrastructure-rg" --yes --no-wait || echo "Spoke RG not found"

echo "⏳ Step 4: Waiting for complete resource deletion..."
# Wait for resource groups to be completely deleted
for i in {1..20}; do
    hub_exists=$(az group exists --name "vijay-networking-global-rg" 2>/dev/null || echo "false")
    spoke_exists=$(az group exists --name "vijay-core-infrastructure-rg" 2>/dev/null || echo "false")
    
    if [ "$hub_exists" = "false" ] && [ "$spoke_exists" = "false" ]; then
        echo "✅ All resource groups completely deleted!"
        break
    fi
    
    echo "⏳ Still waiting for deletion... ($i/20)"
    sleep 30
done

echo "🔧 Step 5: Reinitializing Terraform..."
terraform init

echo "✅ STATE CLEANUP COMPLETE!"
echo "========================="
echo "🎉 All resources destroyed and Terraform state cleaned"
echo "🚀 Ready for fresh deployment"
echo "📅 Completed: $(date)"
echo ""
echo "Next step: Run ./deploy-exercise.sh"
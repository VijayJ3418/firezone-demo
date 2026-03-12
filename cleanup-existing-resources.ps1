# PowerShell script to clean up existing Azure resources that conflict with Terraform
# Run this if you prefer to delete existing resources rather than import them

# Variables
$subscriptionId = "95fe2b5a-17cb-4b4c-b5ca-36c90e4dfefd"
$resourceGroupName = "vijay-core-infrastructure-rg"
$secondaryResourceGroupName = "vijay-core-infrastructure-secondary-rg"
$publicIpName = "vijay-firezone-lb-pip"

Write-Host "Cleaning up existing Azure resources that conflict with Terraform..." -ForegroundColor Yellow

# Login to Azure (if not already logged in)
# az login

# Set subscription
az account set --subscription $subscriptionId

# Delete the existing public IP if it exists
Write-Host "Checking for existing public IP: $publicIpName" -ForegroundColor Cyan
$existingPip = az network public-ip show --resource-group $resourceGroupName --name $publicIpName --query "id" -o tsv 2>$null

if ($existingPip) {
    Write-Host "Deleting existing public IP: $publicIpName" -ForegroundColor Red
    az network public-ip delete --resource-group $resourceGroupName --name $publicIpName
    Write-Host "Public IP deleted successfully" -ForegroundColor Green
} else {
    Write-Host "Public IP $publicIpName not found or already deleted" -ForegroundColor Green
}

# Delete the secondary resource group if it exists and is empty
Write-Host "Checking for existing secondary resource group: $secondaryResourceGroupName" -ForegroundColor Cyan
$existingRg = az group show --name $secondaryResourceGroupName --query "id" -o tsv 2>$null

if ($existingRg) {
    Write-Host "Found secondary resource group. Checking if it's empty..." -ForegroundColor Yellow
    $resources = az resource list --resource-group $secondaryResourceGroupName --query "length(@)" -o tsv
    
    if ($resources -eq "0") {
        Write-Host "Deleting empty secondary resource group: $secondaryResourceGroupName" -ForegroundColor Red
        az group delete --name $secondaryResourceGroupName --yes --no-wait
        Write-Host "Secondary resource group deletion initiated" -ForegroundColor Green
    } else {
        Write-Host "Secondary resource group contains $resources resources. Manual cleanup required." -ForegroundColor Yellow
    }
} else {
    Write-Host "Secondary resource group $secondaryResourceGroupName not found or already deleted" -ForegroundColor Green
}

Write-Host "Cleanup completed. You can now run terraform apply in Terraform Cloud." -ForegroundColor Green
Write-Host "Note: Resource group deletion may take a few minutes to complete." -ForegroundColor Yellow
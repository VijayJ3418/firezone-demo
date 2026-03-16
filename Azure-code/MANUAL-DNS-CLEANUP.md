# Manual DNS Zone Cleanup Guide

## 🚨 **Issue**: Terraform Cannot Delete DNS Zone

Terraform is stuck trying to delete a DNS zone that has dependencies. We need to manually clean this up.

## 🔧 **Manual Cleanup Steps**

### **Step 1: Delete ALL VNet Links**
1. **Go to Azure Portal**
2. **Navigate to**: Resource Groups → `vijay-core-it-infrastructure-rg`
3. **Find**: Private DNS Zone `dglearn.online`
4. **Click on the DNS zone** to open it
5. **Go to**: Virtual network links (left menu)
6. **Delete ALL links** you see:
   - `vijay-core-it-dns-link` (if exists)
   - `vijay-hub-dns-link` (if exists)
   - Any other links

### **Step 2: Delete the DNS Zone**
1. **Still in the DNS zone** `dglearn.online`
2. **Click**: Delete (top menu)
3. **Confirm deletion**
4. **Wait for deletion** to complete

### **Step 3: Verify Cleanup**
1. **Go back to**: Resource Groups → `vijay-core-it-infrastructure-rg`
2. **Verify**: No Private DNS Zone named `dglearn.online` exists
3. **Check**: Resource list is clean

## 🎯 **Alternative: PowerShell Cleanup**

If you have Azure CLI/PowerShell access:

```powershell
# Delete all VNet links first
az network private-dns link vnet delete \
  --resource-group vijay-core-it-infrastructure-rg \
  --zone-name dglearn.online \
  --name vijay-core-it-dns-link \
  --yes

az network private-dns link vnet delete \
  --resource-group vijay-core-it-infrastructure-rg \
  --zone-name dglearn.online \
  --name vijay-hub-dns-link \
  --yes

# Then delete the DNS zone
az network private-dns zone delete \
  --resource-group vijay-core-it-infrastructure-rg \
  --name dglearn.online \
  --yes
```

## 🚀 **After Cleanup**

Once the DNS zone is completely removed:

1. **Push the updated code** to GitHub (with count = 0 fix)
2. **Terraform Cloud will detect** the changes
3. **Apply should succeed** this time
4. **NSG rules will be applied** 
5. **Firezone VMs will be recreated** with internet access

## 📋 **Why This Works**

- **count = 0**: Forces Terraform to ignore these resources
- **Manual deletion**: Removes the actual Azure resources
- **Clean state**: Terraform won't try to manage what doesn't exist

## ⚠️ **Important Notes**

- **We don't need this DNS zone** - the spoke network already has one
- **This is safe to delete** - it's a duplicate that's causing conflicts
- **DNS will still work** through the existing zone in the spoke network

## 🎯 **Expected Result**

After cleanup and reapply:
- ✅ DNS zone conflict resolved
- ✅ NSG outbound rules applied
- ✅ Firezone VMs recreated with internet access
- ✅ Gateways connect to Firezone control plane
- ✅ Admin console shows "Online Gateways"
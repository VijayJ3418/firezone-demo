# How to Remove DNS Zone from Terraform Cloud State

## 🎯 **STEP-BY-STEP INSTRUCTIONS**

### **Method 1: Using Terraform Cloud Web UI (Recommended)**

#### **Step 1: Access Your Terraform Cloud Workspace**
1. Go to [https://app.terraform.io](https://app.terraform.io)
2. Sign in to your Terraform Cloud account
3. Navigate to your workspace (the one containing your Azure infrastructure)

#### **Step 2: Open the Workspace Settings**
1. Click on your workspace name
2. Look for the **"Settings"** tab in the workspace navigation
3. Click on **"General"** under Settings

#### **Step 3: Access the State Management**
1. In the workspace, look for **"States"** tab or **"State"** section
2. Click on the current state version (usually shows as "Current")
3. Look for **"Actions"** or **"Advanced"** options

#### **Step 4: Open Remote Console/CLI Access**
1. Look for **"CLI-driven workflow"** or **"Remote operations"** 
2. Find the option to **"Download CLI configuration"** or **"Remote backend configuration"**
3. Or look for **"Run CLI commands"** option

### **Method 2: Using Terraform CLI with Remote Backend (Alternative)**

#### **Step 1: Set up Local Terraform CLI**
1. Ensure you have Terraform CLI installed locally
2. Create a temporary directory for this operation
3. Create a `main.tf` file with your remote backend configuration:

```hcl
terraform {
  cloud {
    organization = "YOUR_ORG_NAME"
    workspaces {
      name = "YOUR_WORKSPACE_NAME"
    }
  }
}
```

#### **Step 2: Initialize and Authenticate**
```bash
# Initialize Terraform with remote backend
terraform init

# Login to Terraform Cloud (if not already logged in)
terraform login
```

#### **Step 3: Run the State Removal Command**
```bash
# Remove the DNS zone from state
terraform state rm 'module.azure_core_it_infrastructure.azurerm_private_dns_zone.core_it_dns[0]'
```

### **Method 3: Using Terraform Cloud API (Advanced)**

#### **Step 1: Get Your API Token**
1. In Terraform Cloud, go to **User Settings** → **Tokens**
2. Create a new API token
3. Copy the token securely

#### **Step 2: Use curl or similar tool**
```bash
# Get workspace ID first
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  https://app.terraform.io/api/v2/organizations/YOUR_ORG/workspaces/YOUR_WORKSPACE

# Then use the workspace ID to manage state
# (This method is more complex and requires additional API calls)
```

## 🚀 **RECOMMENDED APPROACH: Method 2 (CLI)**

### **Complete Step-by-Step for CLI Method:**

#### **1. Create a temporary directory:**
```bash
mkdir terraform-state-cleanup
cd terraform-state-cleanup
```

#### **2. Create backend configuration file:**
Create `main.tf`:
```hcl
terraform {
  cloud {
    organization = "YOUR_TERRAFORM_CLOUD_ORG_NAME"
    workspaces {
      name = "YOUR_WORKSPACE_NAME"
    }
  }
}
```

#### **3. Initialize and authenticate:**
```bash
terraform init
terraform login  # Follow the prompts to authenticate
```

#### **4. Remove the problematic DNS zone from state:**
```bash
terraform state rm 'module.azure_core_it_infrastructure.azurerm_private_dns_zone.core_it_dns[0]'
```

#### **5. Verify the removal:**
```bash
terraform state list | grep dns_zone
# Should not show the removed resource
```

## ⚠️ **IMPORTANT NOTES:**

### **What This Command Does:**
- ✅ **Removes the DNS zone from Terraform state** (Terraform forgets about it)
- ✅ **Does NOT delete the actual Azure resource** (DNS zone remains in Azure)
- ✅ **Allows deployment to continue** without DNS conflicts
- ✅ **Safe operation** - no risk of breaking existing DNS resolution

### **What Happens After:**
- The DNS zone will still exist in Azure
- Terraform will no longer try to manage it
- Your deployment can proceed without the DNS conflict error
- The spoke network will continue to manage DNS as intended

## 🎯 **ALTERNATIVE: Skip This Step**

**You can also simply ignore the DNS zone error** because:
- It's **non-blocking** for other resources
- Your Jenkins VM and Application Gateway will still deploy
- The DNS zone will remain functional in Azure
- It's purely a state management issue

## 📋 **NEXT STEPS AFTER STATE REMOVAL:**

1. **Run terraform apply again** in Terraform Cloud
2. **Application Gateway should deploy** with the fixed IP address
3. **Complete infrastructure will be operational**
4. **HTTPS access will work** at `https://jenkins-azure.dglearn.online`

Choose the method that you're most comfortable with. Method 2 (CLI) is usually the most straightforward if you have Terraform CLI available.
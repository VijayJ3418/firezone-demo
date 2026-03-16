# Architecture Clarification - DNS Zones and VPN Access

## 🤔 **QUESTION 1: Why Two DNS Zones Created on Each VNet?**

### **Current DNS Zone Architecture:**

```
DNS Zone: dglearn.online
├── Created in: Spoke Network (192.168.0.0/16) ✅ CORRECT
├── Accidentally created in: Core IT Infrastructure (10.0.0.0/16) ❌ DUPLICATE
└── Purpose: Resolve jenkins-azure.dglearn.online to private IPs
```

### **Why This Happened:**
1. **Original Design**: DNS zone was supposed to be created only in **Spoke Network**
2. **Configuration Error**: Core IT Infrastructure module also tried to create the same DNS zone
3. **Result**: Two identical DNS zones in different VNets causing conflicts

### **Correct Architecture Should Be:**
```
Hub Network (172.16.0.0/16)
├── Firezone VPN Gateways
└── No DNS zone needed

Core IT Infrastructure (10.0.0.0/16)  
├── Jenkins VM (10.0.1.x)
├── Application Gateway (10.0.2.x)
└── No DNS zone needed ✅ FIXED

Spoke Network (192.168.0.0/16)
├── DNS Zone: dglearn.online ✅ ONLY HERE
├── VNet Links to Hub and Core IT
└── Resolves jenkins-azure.dglearn.online → 10.0.2.50 (App Gateway)
```

### **Why Only One DNS Zone is Needed:**
- **Single Source of Truth**: One DNS zone manages all name resolution
- **VNet Links**: DNS zone links to all VNets that need name resolution
- **Centralized Management**: Easier to manage DNS records in one place
- **No Conflicts**: Prevents duplicate zone conflicts

## 🔌 **QUESTION 2: VPN Access Requirements**

### **Your Access Requirements:**
> "We need to access only Jenkins server outside by VPN connection"

### **Current Architecture Provides:**

#### **Option A: VPN-Only Access (Private)**
```
Internet → Firezone VPN → Hub Network → Core IT Network → Jenkins VM
```
- **Access Method**: Connect to Firezone VPN first, then access Jenkins privately
- **Jenkins URL**: `http://10.0.1.x:8080` (private IP)
- **Security**: Maximum security, no public access

#### **Option B: HTTPS Public Access (Current Setup)**
```
Internet → Application Gateway (Public IP) → Jenkins VM (Private IP)
```
- **Access Method**: Direct HTTPS access from internet
- **Jenkins URL**: `https://jenkins-azure.dglearn.online`
- **Security**: SSL termination, but publicly accessible

### **Which Access Method Do You Want?**

**If you want VPN-ONLY access:**
- Disable Application Gateway module
- Access Jenkins only through Firezone VPN
- Use private IP: `http://10.0.1.x:8080`

**If you want both VPN and HTTPS access (current):**
- Keep Application Gateway for public HTTPS
- Also allow VPN access for administration
- Use both: VPN for admin, HTTPS for users

## 🚫 **QUESTION 3: Firezone VPN Gateway Connection Issues**

### **Why Firezone Gateways Show "Waiting for Connection":**

#### **Common Causes:**
1. **Internet Connectivity Issues**
   - Gateways can't reach Firezone API servers
   - NSG rules blocking outbound HTTPS (443)
   - DNS resolution problems

2. **Token Issues**
   - Token expired or invalid
   - Token not properly configured in startup script
   - Token format issues

3. **Startup Script Problems**
   - Script failed to download Firezone
   - Docker installation issues
   - Service startup failures

4. **Network Security Group Issues**
   - Outbound internet access blocked
   - Required ports not open

### **Current NSG Configuration Analysis:**

Looking at your hub NSG rules:
```hcl
# ✅ GOOD: Outbound HTTPS allowed
security_rule {
  name                       = "AllowHTTPSOutbound"
  priority                   = 1000
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "Internet"
}

# ✅ GOOD: Outbound HTTP allowed  
security_rule {
  name                       = "AllowHTTPOutbound"
  priority                   = 1100
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "Internet"
}

# ✅ GOOD: DNS allowed
security_rule {
  name                       = "AllowDNSOutbound"
  priority                   = 1200
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Udp"
  source_port_range          = "*"
  destination_port_range     = "53"
  source_address_prefix      = "*"
  destination_address_prefix = "Internet"
}
```

### **Troubleshooting Steps for Firezone:**

#### **Step 1: Check Gateway Status in Azure**
1. Go to Azure Portal
2. Navigate to your Firezone VMs
3. Check if VMs are running
4. Look at boot diagnostics/serial console

#### **Step 2: Verify Token in Firezone Admin**
1. In Firezone admin portal, go to **Gateways**
2. Check if gateways are listed
3. Verify token is still valid
4. Generate new token if needed

#### **Step 3: Check VM Startup Logs**
SSH into Firezone VMs (if possible) and check:
```bash
# Check if Firezone service is running
sudo systemctl status firezone-gateway

# Check startup logs
sudo journalctl -u firezone-gateway -f

# Check if Docker is running
sudo docker ps

# Check network connectivity
curl -I https://api.firezone.dev
```

#### **Step 4: Common Fixes**
1. **Regenerate Token**: Create new token in Firezone admin
2. **Update terraform.tfvars**: Use new token
3. **Redeploy Gateways**: Run terraform apply
4. **Check NSG Rules**: Ensure outbound internet access

## 🎯 **RECOMMENDATIONS:**

### **For DNS Zone Issue:**
- **Keep current approach**: Remove duplicate DNS zone from state
- **Single DNS zone** in spoke network is correct architecture
- **VNet links** will provide name resolution to all networks

### **For Access Method:**
**Clarify your preference:**
- **VPN-only**: Disable Application Gateway, use private access only
- **Hybrid**: Keep both VPN and HTTPS access (current setup)

### **For Firezone Issues:**
1. **Check VM status** in Azure Portal first
2. **Verify token validity** in Firezone admin
3. **Review startup logs** for specific errors
4. **Test network connectivity** from VMs

Would you like me to help troubleshoot the specific Firezone connectivity issue or clarify the access method you prefer?